# Multi-stage Godot containerization
# Stage 1: Godot binary provider (shared by dev + export stages)
FROM ubuntu:22.04 AS godot-binary

ENV buildTag=1.0
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/godot
RUN wget -q -O godot.zip \
    https://github.com/godotengine/godot-builds/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip && \
    unzip -q godot.zip && \
    rm godot.zip && \
    mv Godot_v4.7-stable_linux.x86_64 godot && \
    chmod +x godot

# Stage 2: Development image with editor
FROM ubuntu:22.04 AS godot-dev

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcursor1 libxinerama1 libxrandr2 libxext6 libx11-6 \
    libfontconfig1 libasound2 libgl1-mesa-glx ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=godot-binary /opt/godot/godot /usr/local/bin/godot

WORKDIR /project

EXPOSE 6006 6007 6008

# Run editor: docker run -it --rm -v $(pwd):/project qv-world:dev godot --editor
CMD ["godot"]

# Stage 3: Export/headless build stage
FROM ubuntu:22.04 AS godot-export

ENV DEBIAN_FRONTEND=noninteractive
# Allow override of templates at build time
ARG GODOT_VERSION=4.7.stable
ARG GODOT_TEMPLATES_URL="https://downloads.tuxfamily.org/godotengine/4.7/Godot_v4.7-stable_export_templates.zip"
# SKIP_TEMPLATES when true prevents downloading templates during image build (useful for local dev or if you mount at runtime)
ARG SKIP_TEMPLATES=false

# Install runtime libs Godot expects plus tools to fetch templates
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcursor1 libxinerama1 libxrandr2 libxext6 libx11-6 \
    libasound2 libgl1-mesa-glx libfontconfig1 curl unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=godot-binary /opt/godot/godot /usr/local/bin/godot

WORKDIR /project

# Ensure export templates directory exists and optionally fetch templates at image build time
RUN mkdir -p "/root/.local/share/godot/export_templates/${GODOT_VERSION}" && \
    if [ "${SKIP_TEMPLATES}" = "true" ]; then \
      echo "SKIP_TEMPLATES=true: skipping download of Godot export templates"; \
    else \
      echo "Downloading Godot export templates from ${GODOT_TEMPLATES_URL}..." && \
      curl -L -f -o /tmp/godot_export_templates.zip "${GODOT_TEMPLATES_URL}" && \
      unzip -q /tmp/godot_export_templates.zip -d /tmp/godot_export_templates && \
      mv /tmp/godot_export_templates/* "/root/.local/share/godot/export_templates/${GODOT_VERSION}/" && \
      rm -f /tmp/godot_export_templates.zip; \
    fi

# Export templates should be available from the built image at runtime unless SKIP_TEMPLATES is true.
# If you prefer to override templates at runtime, mount a directory at
# /root/.local/share/godot/export_templates/${GODOT_VERSION}
COPY docker-export-entrypoint.sh /usr/local/bin/docker-export-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-export-entrypoint.sh"]
CMD ["--headless", "--export-debug", "Linux", "export/qv-world.x86_64"]
