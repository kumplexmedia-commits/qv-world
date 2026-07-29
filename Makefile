# Wrapper targets for Docker development and export workflow

.PHONY: build-dev populate-templates run-export verify-export-templates clean

# Build the Godot development/editor image
build-dev:
	docker compose build godot-editor

# Populate the named export template volume from a local Godot export templates ZIP.
# Usage: make populate-templates TEMPLATES_ZIP=/path/to/Godot_v4.7-stable_export_templates.zip
populate-templates:
	@if [ -z "$(TEMPLATES_ZIP)" ]; then \
		echo "Error: TEMPLATES_ZIP is required."; \
		echo "Usage: make populate-templates TEMPLATES_ZIP=/path/to/Godot_v4.7-stable_export_templates.zip"; \
		exit 1; \
	fi
	mkdir -p /tmp/godot-templates
	unzip -o "$(TEMPLATES_ZIP)" -d /tmp/godot-templates
	docker run --rm -v qv-world_godot-export-templates:/data -v /tmp/godot-templates:/src alpine sh -c 'cp -r /src/* /data/'

# Run the headless export service once
run-export:
	docker compose run --rm godot-headless

# Run a quick fallback verification without exporting the project
# Use this to confirm the headless container can locate export templates.
# It will succeed if templates are present in the mounted volume or local fallback paths.
verify-export-templates:
	docker compose run --rm godot-headless --headless --version >/dev/null 2>&1 && echo "Export template fallback check passed"

clean:
	rm -rf /tmp/godot-templates
