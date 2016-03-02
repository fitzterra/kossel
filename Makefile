STLDIR = stl
GCODEDIR = gcode

all: logotype.stl m5_internal.stl frame_top.stl frame_motor.stl carriage.stl endstop.stl \
glass_tab.stl effector.stl retractable.stl power_supply.stl extruder.stl \
frame_extruder.stl glass_frame.stl plate_3x.stl plate_1x.stl \
switch_holder.stl hotend_fan.stl card.stl

.SECONDARY:

# Explicit wildcard expansion suppresses errors when no files are found.
include $(wildcard *.deps)

# Frame motor depends on the kossel logo
frame_motor.stl: | $(STLDIR)/logotype.stl $(STLDIR)/frame_motor.stl
	echo $@

# Effector depends on the M5 Internal thread
effector.stl: | $(STLDIR)/m5_internal.stl $(STLDIR)/effector.stl
	echo $@

# Card depends on the kossel logo
card.stl: | $(STLDIR)/logotype.stl $(STLDIR)/card.stl
	echo $@

.PHONY: %.stl
%.stl: $(STLDIR)/%.stl
	echo $<


# Getting errors truing to use meshlab server to clean STL at the moment.
# Until this is solved, we rely on the OpenSCAD generated STL which should be
# fine really.
$(STLDIR)/%.stl: %.scad
	openscad -m make -o $@ $<

## This is the block we should run when the meshlab issue is resolved:
#$(STLDIR)/%.stl: $(STLDIR)/%.ascii.stl
#	meshlabserver -i $< -o $@ -s meshclean.mlx
#
#$(STLDIR)/%.ascii.stl: %.scad
#	openscad -m make -d $(STLDIR)/$*.deps -o $@ $<

.PHONY: %.gcode
%.gcode: $(GCODEDIR)/%.gcode
	echo $<

$(GCODEDIR)/%.gcode: $(STLDIR)/%.stl
	slic3r -o $@ $<

# Replace tabs with spaces.
%.tab: %.scad
	cp $< $@
	expand $@ > $<

.PHONY: clean
clean:
	rm -f $(STLDIR)/* $(GCODEDIR)/*
