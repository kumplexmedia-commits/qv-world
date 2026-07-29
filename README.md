# qv-world

This repository contains the `qv-world` Godot project and Docker support for editor and headless export workflows.

## Docker

The `Dockerfile` builds two main targets:

- `godot-dev`: development/editor image
- `godot-export`: headless export image

### Export templates

The export stage does not download Godot templates during build. Instead, it expects export templates to be provided via a mounted local volume at runtime.

The Compose service `godot-headless` already mounts:

- `godot-export-templates:/root/.local/share/godot/export_templates`

This volume is treated as an external export template cache, so it should be populated using `make populate-templates` before running the headless service.

To export builds successfully, ensure the mounted volume contains the required Godot export templates under:

- `/root/.local/share/godot/export_templates/4.7.stable`

If your environment cannot reach `downloads.tuxfamily.org`, the export container now supports two local fallback methods:

1. Place `Godot_v4.7-stable_export_templates.zip` in the project root.
2. Place extracted templates under `./export_templates/4.7.stable` in the project root.

If neither is available, populate the named volume manually with local export template contents.

For example, if you have the zip locally:

```bash
mkdir -p /tmp/godot-templates && unzip Godot_v4.7-stable_export_templates.zip -d /tmp/godot-templates
# Copy the extracted templates into the named volume
docker run --rm -v qv-world_godot-export-templates:/data -v /tmp/godot-templates:/src alpine sh -c 'cp -r /src/* /data/'
```

## Running

Start the editor service:

```bash
docker compose up godot-editor
```

Start the headless export service:

```bash
docker compose up godot-headless
```

Verify the export template fallback logic without exporting the project:

```bash
make verify-export-templates
```
