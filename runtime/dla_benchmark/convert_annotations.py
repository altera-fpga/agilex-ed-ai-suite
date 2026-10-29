#!/usr/bin/env python3
# ============================================================================
# This script takes two paths as input. The first path is to the annotation file
# in json format. This annotation file is the validation data used in the 2017 COCO
# competition for object detection, downloaded from https://cocodataset.org/
# The second path indicates the folder where the user wants to store the converted
# annotation files in plain text format. Each file in the destination folder contains
# the true label and the bounding boxes for its corresponding validation image.
# To use the average precision calculation in the dla_benchmark, you must
# provide the text-formatted annotation files.
# Note that 91 classes are used in the mscoco paper https://arxiv.org/pdf/1405.0312.pdf,
# whereas 80 are used in validation 2014/2017 dataset.
# ============================================================================

import json
import sys


def cat80(cat: int) -> int:
    '''
    The validation dataset omits 11 classes and causes mismatches with
    the predicted classes in the benckmark_app. This function maps the
    class id from the json annotation file to those used in the dla_benchmark.
    '''
    diff = 1
    if cat > 11:
        diff += 1
    if cat > 25:
        diff += 1
    if cat > 28:
        diff += 2
    if cat > 44:
        diff += 1
    if cat > 65:
        diff += 1
    if cat > 67:
        diff += 2
    if cat > 70:
        diff += 1
    if cat > 82:
        diff += 1
    if cat > 90:
        diff += 1
    return cat - diff


def parse_annotation_file(path_to_annotation: str, destination_folder: str) -> int:
    fin = open(path_to_annotation)
    json_data = json.load(fin)
    per_image_data = dict()

    # Gets all bounding boxes and labels w.r.t. each validation image.
    for annotation in json_data["annotations"]:
        image_id = annotation["image_id"]
        bbox_data = [str(cat80(annotation["category_id"]))] + list(map(str, annotation["bbox"]))
        if image_id in per_image_data:
            per_image_data[image_id].append(bbox_data)
        else:
            per_image_data[image_id] = [bbox_data]
    fin.close()

    # Creates and writes to text files.
    for image_meta in json_data["images"]:
        file_path = rf'{destination_folder}/{image_meta["file_name"][:-4]}.txt'
        if image_meta["id"] in per_image_data:
            bboxes = per_image_data[image_meta["id"]]
        else:
            bboxes = []
        with open(file_path, "w") as fout:
            fout.write("\n".join([" ".join(bbox) for bbox in bboxes]))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(
            ("Usage: {0} "
             "<path to the validation file in json format> "
             "<path to the folder to store the annotation text files> "
             )
            .format(sys.argv[0]))

    json_instances = sys.argv[1]
    destination = sys.argv[2]

    try:
        parse_annotation_file(json_instances, destination)
    except Exception as err:
        print(err)
    else:
        print("Finished.")
