# Agilex 5 Modular OFS PCIe

## Known Issue

If bitstream generation fails with the default AXI bridge/mux capability settings
(**16**), replace the AFU Platform Designer script used by the build with the
alternate file that raises those capabilities to **32**.

Keep the original filename; `setup_project.sh` symlinks
`dla_afu_hw_agx5e_modular_ofs_pcie.tcl` → `dla_afu_hw.tcl`.

```bash
cd platform/agx5e_modular_ofs_pcie

cp dla_afu_hw_agx5e_modular_ofs_pcie.tcl \
   dla_afu_hw_agx5e_modular_ofs_pcie.tcl.bak

cp dla_afu_hw_agx5e_modular_ofs_pcie_timing_relaxed.tcl \
   dla_afu_hw_agx5e_modular_ofs_pcie.tcl
```

Then rebuild the example design as usual.
