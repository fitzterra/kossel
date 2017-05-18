STLDIR = stl
GCODEDIR = gcode

all: logotype.stl m5_internal.stl frame_top.stl frame_motor.stl carriage.stl \
carriage2.stl endstop.stl glass_tab.stl effector.stl retractable.stl \
power_supply.stl extruder.stl frame_extruder.stl glass_frame.stl plate_3x.stl \
plate_1x.stl switch_holder.stl hotend_fan.stl card.stl tower_slides.stl \
rod_connector.stl glass_grip_tab.stl effector_e3d_v5.stl effector_e3d_v6.stl \
effector_e3d_v5_plate.stl effector_e3d_v6_plate.stl effector_e3d_v5_effector.stl \
effector_e3d_v6_effector.stl effector_e3d_v5_posts.stl effector_e3d_v5_mount_cap.stl \
effector_e3d_v5_groove_mount.stl effector_e3d_v5_pen_holder.stl z-probe_detachable.stl

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

# This is for the full effector and hotend STL to use in full printer model
$(STLDIR)/effector_e3d_v5.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=false -D 'renderParts=["effector","posts","groove_mount","mount_cap","hotend"]' $<
$(STLDIR)/effector_e3d_v6.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=6 -D print=false -D 'renderParts=["all"]' $<

# This is for building a plate from all the parts in effector_e3d.scad
$(STLDIR)/effector_e3d_v5_plate.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=true -D 'renderParts=["all"]' $<
$(STLDIR)/effector_e3d_v6_plate.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=6 -D print=true -D 'renderParts=["all"]' $<

# The E3D effector only
$(STLDIR)/effector_e3d_v5_effector.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=true -D 'renderParts=["effector"]' $<
$(STLDIR)/effector_e3d_v6_effector.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=6 -D print=true -D 'renderParts=["effector"]' $<

# The E3D effector mount posts
$(STLDIR)/effector_e3d_v5_posts.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=true -D 'renderParts=["posts"]' $<

# The E3D effector mount cap
$(STLDIR)/effector_e3d_v5_mount_cap.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=true -D 'renderParts=["mount_cap"]' $<

# The E3D effector groove mount
$(STLDIR)/effector_e3d_v5_groove_mount.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=true -D 'renderParts=["groove_mount"]' $<

# The pen holder fitting the E3D effector
$(STLDIR)/effector_e3d_v5_pen_holder.stl: effector_e3d.scad
	openscad -m make -o $@ -D hotend=5 -D print=true -D 'renderParts=["pen_holder"]' $<

# The detachable Z-Probe and cradle
$(STLDIR)/z-probe_detachable.stl: z-probe_detachable.scad
	openscad -m make -o $@ -D print=true $<

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
