#!/usr/bin/env python3
"""
Train a simple MLP for Keyword Spotting on Speech Commands dataset.

This script trains a Multi-Layer Perceptron (MLP) to classify spoken keywords
using the Google Speech Commands v2 dataset from Kaggle.

Usage:
    # Train a new model from scratch (downloads dataset automatically from Kaggle):
    python3 train_kws_mlp.py

    # Train with custom architecture and hyperparameters:
    python3 train_kws_mlp.py --output-dir ./models \\
                             --epochs 100 \\
                             --batch-size 64 \\
                             --hidden-units 256 128 64

Output files (written to --output-dir):
    kws_mlp.xml            - OpenVINO IR model (graph)
    kws_mlp.bin            - OpenVINO IR model (weights)
    test_inputs_fp32.npy   - Test input samples in FP32
    test_inputs_bfp16.bin  - Test input samples in BFP16 binary format
    test_outputs_fp32.npy  - Model predictions in FP32
    test_outputs_bfp16.bin - Model predictions in BFP16 binary format
    test_labels.npy        - Ground truth labels for test samples
    test_metadata.json     - Metadata (shapes, class names, num samples, etc.)
    class_names.txt        - List of class names (one per line)
"""

import argparse
import sys
from pathlib import Path

import librosa
import numpy as np
from tensorflow import keras
from tensorflow.keras import layers


def load_speech_commands_dataset(data_path: Path, target_keywords: list = None):
    """Load and preprocess Speech Commands dataset.

    Args:
        data_path: Path to downloaded dataset
        target_keywords: List of keywords to classify. If None, uses default 10 keywords.

    Returns:
        Tuple of (X_train, y_train, X_val, y_val, X_test, y_test, class_names)
    """
    if target_keywords is None:
        # Default 10 keywords for easy classification
        target_keywords = [
            'yes', 'no', 'up', 'down', 'left', 'right', 'on', 'off', 'stop', 'go'
        ]

    # Add silence and unknown classes
    class_names = target_keywords + ['_silence_', '_unknown_']
    num_classes = len(class_names)

    print(f"Loading dataset from: {data_path}")
    print(f"Target keywords: {target_keywords}")
    print(f"Total classes: {num_classes}")

    # Audio parameters
    sample_rate = 16000
    duration = 1.0  # 1 second
    n_mfcc = 40  # Number of MFCC features

    X_train, y_train = [], []
    X_val, y_val = [], []
    X_test, y_test = [], []

    # Load validation and test file lists
    validation_list_path = data_path / "validation_list.txt"
    testing_list_path = data_path / "testing_list.txt"

    validation_files = set()
    testing_files = set()

    if validation_list_path.exists():
        with open(validation_list_path, 'r') as f:
            validation_files = set(line.strip() for line in f)

    if testing_list_path.exists():
        with open(testing_list_path, 'r') as f:
            testing_files = set(line.strip() for line in f)

    # Process each keyword directory
    for class_idx, keyword in enumerate(class_names):
        if keyword in ['_silence_', '_unknown_']:
            continue

        keyword_path = data_path / keyword
        if not keyword_path.exists():
            print(f"Warning: Directory not found for keyword '{keyword}'")
            continue

        wav_files = list(keyword_path.glob("*.wav"))
        print(f"Processing {keyword}: {len(wav_files)} files")

        for wav_file in wav_files:
            relative_path = f"{keyword}/{wav_file.name}"

            # Extract MFCC features
            features = extract_features(wav_file, sample_rate, n_mfcc)
            if features is None:
                continue

            # Split into train/val/test
            if relative_path in validation_files:
                X_val.append(features)
                y_val.append(class_idx)
            elif relative_path in testing_files:
                X_test.append(features)
                y_test.append(class_idx)
            else:
                X_train.append(features)
                y_train.append(class_idx)

    # Add silence samples (background noise)
    background_path = data_path / "_background_noise_"
    if background_path.exists():
        silence_idx = class_names.index('_silence_')
        noise_files = list(background_path.glob("*.wav"))
        print(f"Processing silence: {len(noise_files)} files")

        for noise_file in noise_files:
            # Extract multiple 1-second segments from each noise file
            audio, sr = librosa.load(noise_file, sr=sample_rate)
            segment_length = int(sample_rate * duration)

            # Generate 10 random segments per noise file
            for _ in range(10):
                if len(audio) > segment_length:
                    start = np.random.randint(0, len(audio) - segment_length)
                    segment = audio[start:start + segment_length]
                else:
                    segment = audio

                features = extract_features_from_audio(segment, sample_rate, n_mfcc)
                if features is not None:
                    X_train.append(features)
                    y_train.append(silence_idx)

    # Convert to numpy arrays
    X_train = np.array(X_train)
    y_train = np.array(y_train)
    X_val = np.array(X_val)
    y_val = np.array(y_val)
    X_test = np.array(X_test)
    y_test = np.array(y_test)

    print("\nDataset splits:")
    print(f"  Training: {X_train.shape}")
    print(f"  Validation: {X_val.shape}")
    print(f"  Testing: {X_test.shape}")

    return X_train, y_train, X_val, y_val, X_test, y_test, class_names


def extract_features(audio_path: Path, sample_rate: int = 16000, n_mfcc: int = 40):
    """Extract MFCC features from audio file.

    Args:
        audio_path: Path to audio file
        sample_rate: Target sample rate
        n_mfcc: Number of MFCC coefficients

    Returns:
        Flattened MFCC features or None if error
    """
    try:
        # Load audio file
        audio, sr = librosa.load(audio_path, sr=sample_rate, duration=1.0)
        return extract_features_from_audio(audio, sample_rate, n_mfcc)
    except Exception as e:
        print(f"Error processing {audio_path}: {e}")
        return None


def extract_features_from_audio(audio: np.ndarray, sample_rate: int, n_mfcc: int):
    """Extract MFCC features from audio signal.

    Args:
        audio: Audio signal
        sample_rate: Sample rate
        n_mfcc: Number of MFCC coefficients

    Returns:
        Flattened MFCC features
    """
    # Pad or trim to 1 second
    target_length = sample_rate
    if len(audio) < target_length:
        audio = np.pad(audio, (0, target_length - len(audio)))
    else:
        audio = audio[:target_length]

    # Extract MFCC features
    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=n_mfcc)

    # Flatten the MFCC features (n_mfcc x time_frames)
    features = mfcc.flatten()

    return features


def create_mlp_model(input_shape: tuple, num_classes: int, hidden_units: list = None):
    """Create a simple MLP model for keyword spotting.

    Args:
        input_shape: Shape of input features
        num_classes: Number of output classes
        hidden_units: List of hidden layer sizes. Default: [128, 64]

    Returns:
        Compiled Keras model
    """
    if hidden_units is None:
        hidden_units = [128, 64]

    model = keras.Sequential([
        layers.Input(shape=input_shape),
        layers.Dense(hidden_units[0], activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(hidden_units[1], activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(num_classes, activation='softmax')
    ])

    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )

    return model


def train_model(model, X_train, y_train, X_val, y_val, epochs: int = 50, batch_size: int = 32):
    """Train the model.

    Args:
        model: Keras model
        X_train, y_train: Training data
        X_val, y_val: Validation data
        epochs: Number of training epochs
        batch_size: Batch size

    Returns:
        Training history
    """
    callbacks = [
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=5,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=3,
            min_lr=1e-6
        )
    ]

    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        callbacks=callbacks,
        verbose=1
    )

    return history


def main():
    parser = argparse.ArgumentParser(
        description="Train MLP for Keyword Spotting",
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("./models"),
        help="Output directory for trained model"
    )

    parser.add_argument(
        "--epochs",
        type=int,
        default=50,
        help="Number of training epochs"
    )

    parser.add_argument(
        "--batch-size",
        type=int,
        default=32,
        help="Batch size for training"
    )

    parser.add_argument(
        "--hidden-units",
        type=int,
        nargs='+',
        default=[128, 64],
        help="Hidden layer sizes (e.g., --hidden-units 256 128 64)"
    )

    args = parser.parse_args()

    # Download dataset from Kaggle
    try:
        import kagglehub
        print("Downloading Speech Commands dataset from Kaggle...")
        data_path = Path(kagglehub.dataset_download("sylkaladin/speech-commands-v2"))
    except ImportError:
        print("Error: kagglehub not installed. Install with: pip install kagglehub")
        sys.exit(1)

    # Load dataset
    X_train, y_train, X_val, y_val, X_test, y_test, class_names = load_speech_commands_dataset(data_path)

    # Create model
    input_shape = (X_train.shape[1],)
    num_classes = len(class_names)

    print("\nCreating MLP model:")
    print(f"  Input shape: {input_shape}")
    print(f"  Hidden layers: {args.hidden_units}")
    print(f"  Output classes: {num_classes}")

    model = create_mlp_model(input_shape, num_classes, args.hidden_units)
    model.summary()

    # Train model
    print("\nTraining model...")
    train_model(
        model, X_train, y_train, X_val, y_val,
        epochs=args.epochs,
        batch_size=args.batch_size
    )

    # Evaluate on test set
    print("\nEvaluating on test set...")
    test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test accuracy: {test_acc:.4f}")

    # Save model
    args.output_dir.mkdir(parents=True, exist_ok=True)

    # Convert to OpenVINO IR
    print("\nConverting to OpenVINO IR...")
    try:
        import openvino as ov
        from openvino.runtime import PartialShape

        # Convert Keras model to OpenVINO (use model object, not file path)
        # Set input shape explicitly to avoid dynamic dimensions
        input_shape_full = [1] + list(input_shape)  # Add batch dimension
        ov_model = ov.convert_model(model, input=input_shape_full)

        # Verify no dynamic shapes
        for input_node in ov_model.inputs:
            shape = input_node.get_partial_shape()
            if shape.is_dynamic:
                print(f"Warning: Dynamic shape detected in input: {input_node.get_any_name()}")
                # Reshape to static
                static_shape = []
                for dim in shape:
                    if dim.is_dynamic:
                        static_shape.append(1)
                    else:
                        static_shape.append(dim.get_length())
                print(f"  Reshaping to static: {static_shape}")
                ov_model.reshape({input_node.get_any_name(): PartialShape(static_shape)})

        # Save OpenVINO IR
        ov_path = args.output_dir / "kws_mlp.xml"
        ov.save_model(ov_model, ov_path)
        print(f"Saved OpenVINO IR to: {ov_path}")
        print(f"                      {args.output_dir / 'kws_mlp.bin'}")

        # Print final shapes to confirm
        print("\nModel Input/Output Shapes:")
        for idx, input_node in enumerate(ov_model.inputs):
            print(f"  Input[{idx}]: {input_node.get_shape()} ({input_node.get_element_type()})")
        for idx, output_node in enumerate(ov_model.outputs):
            print(f"  Output[{idx}]: {output_node.get_shape()} ({output_node.get_element_type()})")

    except Exception as e:
        print(f"Warning: Failed to convert to OpenVINO: {e}")
        import traceback
        traceback.print_exc()

    # Save test samples as BFP16 for hardware testing
    print("\nSaving test samples...")
    num_samples = min(10, len(X_test))

    # Helper function to convert to BFP16
    def to_bfp16(data):
        """Convert float32 to BFP16 (Brain Floating Point 16)"""
        # BFP16: truncate FP32 mantissa from 23 bits to 7 bits
        # Keep sign (1 bit) and exponent (8 bits)
        fp32_bits = data.view(np.uint32)
        bfp16_bits = (fp32_bits >> 16).astype(np.uint16)
        return bfp16_bits

    def from_bfp16(data):
        """Convert BFP16 back to float32 for validation"""
        fp32_bits = data.astype(np.uint32) << 16
        return fp32_bits.view(np.float32)

    # Select random test samples
    sample_indices = np.random.choice(len(X_test), num_samples, replace=False)
    X_samples = X_test[sample_indices].astype(np.float32)
    y_samples = y_test[sample_indices]

    # Get model predictions for the samples
    y_pred = model.predict(X_samples, verbose=0)

    # Convert to BFP16
    X_samples_bfp16 = to_bfp16(X_samples)
    y_pred_bfp16 = to_bfp16(y_pred)

    # Convert BFP16 back to FP32 for exact bit representation matching
    X_samples_fp32_from_bfp16 = from_bfp16(X_samples_bfp16)
    y_pred_fp32_from_bfp16 = from_bfp16(y_pred_bfp16)

    # Save inputs as FP32 .npy
    np.save(args.output_dir / "test_inputs_fp32.npy", X_samples_fp32_from_bfp16)
    print(f"Saved test inputs (FP32 from BFP16) to: {args.output_dir / 'test_inputs_fp32.npy'}")

    # Save inputs as BFP16 .bin
    X_samples_bfp16.tofile(args.output_dir / "test_inputs_bfp16.bin")
    print(f"Saved test inputs (BFP16) to: {args.output_dir / 'test_inputs_bfp16.bin'}")

    # Save expected outputs as FP32 .npy
    np.save(args.output_dir / "test_outputs_fp32.npy", y_pred_fp32_from_bfp16)
    print(f"Saved test outputs (FP32 from BFP16) to: {args.output_dir / 'test_outputs_fp32.npy'}")

    # Save expected outputs as BFP16 .bin
    y_pred_bfp16.tofile(args.output_dir / "test_outputs_bfp16.bin")
    print(f"Saved test outputs (BFP16) to: {args.output_dir / 'test_outputs_bfp16.bin'}")

    # Save ground truth labels
    np.save(args.output_dir / "test_labels.npy", y_samples)
    print(f"Saved test labels to: {args.output_dir / 'test_labels.npy'}")

    # Save metadata
    metadata = {
        'num_samples': num_samples,
        'test_input_shape': list(X_samples.shape),
        'test_output_shape': list(y_pred.shape),
        'input_tensor_shape': [1] + list(input_shape),  # [batch, features]
        'output_tensor_shape': [1, num_classes],  # [batch, classes]
        'num_classes': num_classes,
        'class_names': class_names
    }
    import json
    with open(args.output_dir / "test_metadata.json", 'w') as f:
        json.dump(metadata, f, indent=2)
    print(f"Saved test metadata to: {args.output_dir / 'test_metadata.json'}")

    # Save class names
    class_names_path = args.output_dir / "class_names.txt"
    class_names_path.write_text('\n'.join(class_names))
    print(f"Saved class names to: {class_names_path}")

    print("\nTraining complete!")


if __name__ == "__main__":
    main()
