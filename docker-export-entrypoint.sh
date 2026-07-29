#!/bin/sh
set -e

if [ -z "$GODOT_VERSION" ]; then
    GODOT_VERSION="4.7.stable"
fi

GODOT_TEMPLATE_LABEL="$(printf '%s' "$GODOT_VERSION" | sed 's/\.stable/-stable/')"
TEMPLATES_DIR="/root/.local/share/godot/export_templates/${GODOT_VERSION}"
LOCAL_ZIP="/project/Godot_v${GODOT_TEMPLATE_LABEL}_export_templates.zip"
LOCAL_DIR1="/project/export_templates/${GODOT_VERSION}"
LOCAL_DIR2="/project/export_templates/${GODOT_TEMPLATE_LABEL}"

check_templates() {
    if [ -d "$TEMPLATES_DIR" ]; then
        if find "$TEMPLATES_DIR" -mindepth 1 | grep -q .; then
            return 0
        fi
    fi
    return 1
}

if ! check_templates; then
    echo "INFO: Godot export templates not found at $TEMPLATES_DIR; attempting local fallback."
    if [ -f "$LOCAL_ZIP" ]; then
        echo "Found local export template ZIP: $LOCAL_ZIP"
        mkdir -p "$TEMPLATES_DIR"
        unzip -oq "$LOCAL_ZIP" -d "$TEMPLATES_DIR"
        echo "Extracted local export templates into $TEMPLATES_DIR"
    elif [ -d "$LOCAL_DIR1" ] && find "$LOCAL_DIR1" -mindepth 1 | grep -q .; then
        echo "Found local export template directory: $LOCAL_DIR1"
        mkdir -p "$TEMPLATES_DIR"
        cp -r "$LOCAL_DIR1"/. "$TEMPLATES_DIR"/
        echo "Copied local export templates into $TEMPLATES_DIR"
    elif [ -d "$LOCAL_DIR2" ] && find "$LOCAL_DIR2" -mindepth 1 | grep -q .; then
        echo "Found local export template directory: $LOCAL_DIR2"
        mkdir -p "$TEMPLATES_DIR"
        cp -r "$LOCAL_DIR2"/. "$TEMPLATES_DIR"/
        echo "Copied local export templates into $TEMPLATES_DIR"
    else
        echo ""
        echo "ERROR: Export templates are missing."
        echo "Expected path: $TEMPLATES_DIR"
        echo ""
        echo "Provide templates by one of these methods:"
        echo "  1. Place ${LOCAL_ZIP} in the project root."
        echo "  2. Add a local export template directory at ./export_templates/${GODOT_VERSION} or ./export_templates/${GODOT_TEMPLATE_LABEL}."
        echo "  3. Populate the named Docker volume with:"
        echo "       make populate-templates TEMPLATES_ZIP=/path/to/${LOCAL_ZIP}"
        echo ""
        exit 1
    fi
fi

exec godot "$@"
