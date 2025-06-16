all:
    @echo "Available command categories:"
    @echo ""
    @echo "  just ansible    - Show Ansible-related commands"
    @echo "  just apps       - Show Application installation commands"
    @echo "  just opentofu   - Show Opentofu hybrid-env commands"
    @echo ""
    @echo "Run the specific category to see detailed commands"

# ==============================================================================
# ANSIBLE COMMANDS
# ==============================================================================

ansible:
    @echo "Available Ansible commands:"
    @echo ""
    @echo "Service Installation:"
    @echo "  just install SERVICE ENV VAULT [LIMIT]    - Install system services"
    @echo ""
    @echo "Docker Service Setup:"
    @echo "  just setup-service ENV SERVICE HOST        - Setup single service (no vault needed)"
    @echo "  just setup-services ENV VAULT SERVICES [HOST] - Setup multiple services"
    @echo "  just setup-stack ENV VAULT STACK [HOST]    - Setup predefined stack"
    @echo ""
    @echo "Docker Service Management:"
    @echo "  just start-service ENV SERVICE HOST        - Start service (no vault needed)"
    @echo "  just stop-service ENV SERVICE HOST         - Stop service (no vault needed)"
    @echo "  just restart-service ENV SERVICE HOST      - Restart service (no vault needed)"
    @echo "  just logs-service ENV SERVICE HOST         - Show service logs (no vault needed)"
    @echo "  just status-service ENV SERVICE HOST       - Show service status (no vault needed)"
    @echo ""
    @echo "System Updates:"
    @echo "  just update-prod-deb VAULT [LIMIT]   - Update Debian/Ubuntu production hosts"
    @echo "  just update-prod-rpm VAULT [LIMIT]   - Update RHEL/Rocky production hosts"
    @echo "  just update-dev VAULT [LIMIT]        - Update Dev host"
    @echo "  just update-all VAULT               - Update all host across infra"
    @echo ""
    @echo "Available system services:"
    @echo "  fossorial        - Install Fossorial Pangolin application"
    @echo "  firewall         - Install and configure Firewalld"
    @echo "  base-pkg         - Install base packages"
    @echo ""
    @echo "Available docker services:"
    @echo "  ai-stack, authentik, beszel, gitea, glance, gotify"
    @echo "  grafana, miniflux, stirling-pdf, traefik, uptime-kuma"
    @echo "  vaultwarden, vikunja, tailscale-lb"
    @echo ""
    @echo "Available stacks:"
    @echo "  core, monitoring, productivity, ai, security, utilities, full"

# Install system services
install SERVICE ENV LIMIT='':  # Remove VAULT temporary
    #!/usr/bin/env bash
    cd ansible
    case "{{SERVICE}}" in
        fossorial)
            playbook="docker/pangolin_install.yml"
            ;;
        firewall)
            playbook="system/base_firewall.yml"
            ;;
        base-pkg)
            playbook="system/base_pkg.yml"
            ;;
        *)
            echo "Error: Unknown service '{{SERVICE}}'"
            echo "Available services: fossorial, *WIP* firewall, base-pkg"
            exit 1
            ;;
    esac
    if [ -z "{{LIMIT}}" ]; then
        ansible-playbook playbooks/$playbook -i inventory/infra/{{ENV}}/hosts.yml
    else
        ansible-playbook playbooks/$playbook -i inventory/infra/{{ENV}}/hosts.yml --limit "{{LIMIT}}"
    fi

# ==============================================================================
# DOCKER SERVICE SETUP COMMANDS (Copy and prepare only)
# ==============================================================================

# From Repo
# Setup single service 
setup-service ENV SERVICE HOST:
    cd ansible && ansible-playbook playbooks/docker/setup-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "services=['{{SERVICE}}']" \
    --limit {{HOST}}

# Setup multiple services
setup-services ENV SERVICES VAULT HOST='':
    #!/usr/bin/env bash
    cd ansible
    SERVICES_YAML=$(echo "{{SERVICES}}" | sed 's/,/", "/g' | sed 's/^/["/' | sed 's/$/"]/')
    ansible-playbook playbooks/docker/setup-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "@vaults/{{VAULT}}" \
    --extra-vars "services=$SERVICES_YAML" \
    $([ ! -z "{{HOST}}" ] && echo "--limit {{HOST}}") \
    --ask-vault-pass

# Setup predefined stacks
setup-stack ENV VAULT STACK HOST='':
    #!/usr/bin/env bash
    cd ansible
    case "{{STACK}}" in
        core)
            SERVICES='["traefik", "authentik"]'
            ;;
        monitoring)
            SERVICES='["grafana", "uptime-kuma", "beszel"]'
            ;;
        productivity)
            SERVICES='["gitea", "vikunja", "miniflux"]'
            ;;
        ai)
            SERVICES='["ai-stack"]'
            ;;
        security)
            SERVICES='["vaultwarden", "authentik"]'
            ;;
        utilities)
            SERVICES='["glance", "gotify", "stirling-pdf"]'
            ;;
        full)
            SERVICES='["traefik", "authentik", "gitea", "grafana", "uptime-kuma", "beszel", "ai-stack", "vaultwarden", "vikunja", "miniflux", "stirling-pdf", "glance", "gotify", "tailscale-lb"]'
            ;;
        *)
            echo "Unknown stack: {{STACK}}"
            echo "Available stacks: core, monitoring, productivity, ai, security, utilities, full"
            exit 1
            ;;
    esac
    ansible-playbook playbooks/docker/setup-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "@vaults/{{VAULT}}" \
    --extra-vars "services=$SERVICES" \
    $([ ! -z "{{HOST}}" ] && echo "--limit {{HOST}}") \
    --ask-vault-pass

# ==============================================================================
# DOCKER SERVICE MANAGEMENT COMMANDS (Container operations only)
# ==============================================================================

# Start service
start-service ENV SERVICE HOST:
    cd ansible && ansible-playbook playbooks/docker/manage-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "services=['{{SERVICE}}']" \
    --extra-vars "operation=start" \
    --limit {{HOST}}

# Stop service
stop-service ENV SERVICE HOST:
    cd ansible && ansible-playbook playbooks/docker/manage-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "services=['{{SERVICE}}']" \
    --extra-vars "operation=stop" \
    --limit {{HOST}}

# Restart service
restart-service ENV SERVICE HOST:
    cd ansible && ansible-playbook playbooks/docker/manage-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "services=['{{SERVICE}}']" \
    --extra-vars "operation=restart" \
    --limit {{HOST}}

# Show service logs
logs-service ENV SERVICE HOST:
    cd ansible && ansible-playbook playbooks/docker/manage-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "services=['{{SERVICE}}']" \
    --extra-vars "operation=logs" \
    --limit {{HOST}}

# Show service status
status-service ENV SERVICE HOST:
    cd ansible && ansible-playbook playbooks/docker/manage-docker-services.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "services=['{{SERVICE}}']" \
    --extra-vars "operation=status" \
    --limit {{HOST}}

# ==============================================================================
# SYSTEM UPDATE COMMANDS
# ==============================================================================

# Update Prod Hosts (Distribution Specific)
update-prod-deb VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/prod/hosts.yml \
    --tags deb_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

update-dev VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/dev/hosts.yml \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

update-prod-rpm VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/prod/hosts.yml \
    --tags rpm_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Update All Production Hosts
INVENTORY_DIR := "inventory/infra"
update-all VAULT:
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i {{INVENTORY_DIR}}/prod/hosts.yml \
    -i {{INVENTORY_DIR}}/dev/hosts.yml \
    -i {{INVENTORY_DIR}}/vps/hosts.yml \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# ==============================================================================
# LEGACY COMMANDS (Deprecated - use new setup/start commands instead)
# ==============================================================================

# Legacy firewall install
firewall-install ENV VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/base_firewall.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --tags dev_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# ==============================================================================
# APPLICATION INSTALLATION COMMANDS
# ==============================================================================

apps:
    @echo "Available Application Installation Commands:"
    @echo ""
    @echo "App Management:"
    @echo "  just install-app ENV APP VAULT [LIMIT]   - Install an application"
    @echo "  just list-apps                          - List available applications"
    @echo ""
    @echo "Parameters:"
    @echo "  ENV   : prod | dev | vps"
    @echo "  APP   : Application name (e.g., jenkins)"
    @echo "  VAULT : Vault file name from ansible/vaults/ (e.g., prod.yml)"
    @echo "  LIMIT : Host group or server (optional)"
    @echo ""
    @echo "Examples:"
    @echo "  just install-app dev jenkins dev.yml         # Install Jenkins on all dev hosts"
    @echo "  just install-app prod jenkins prod.yml proxy # Install Jenkins on specific host"

list-apps:
    @echo "Available applications:"
    @echo ""
    @find ansible/playbooks/apps -name "*_install.yml" 2>/dev/null | sed 's|ansible/playbooks/apps/||g' | sed 's|_install.yml||g' | sort || echo "No apps directory found"

install-app ENV APP VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/install_app.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "app={{APP}} target_hosts={{LIMIT}}" \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# ==============================================================================
# OPENTOFU COMMANDS (Placeholder)
# ==============================================================================

opentofu:
    @echo "Available OpenTofu commands:" (Placeholder)
    @echo ""
    @echo "Infrastructure Management:"
    @echo "  WORK IN PROGRESS"
    @echo ""
    @echo "Examples:"
    @echo "  WORK IN PROGRESS"
