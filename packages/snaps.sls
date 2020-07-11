# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "packages/map.jinja" import packages with context %}

# As we are 'extend'ing pkg_req_pkgs and unwanted_pkgs, we need to concatenate
# the attributes correctly (see #17)
{% set req_packages = packages.pkgs.required.pkgs + packages.snaps.packages %}
{% set req_states = packages.pkgs.required.states + packages.snaps.required.states %}
{% set unwanted_packages = packages.pkgs.unwanted + packages.snaps.collides %}

{% set wanted_snaps = packages.snaps.wanted %}
{% set classic_snaps = packages.snaps.classic %}
{% set unwanted_snaps = packages.snaps.unwanted %}

# Backwards compatibility: if a list was provided, transform it to a dict
{% if wanted_snaps is not mapping %}
{% set wanted_snaps = dict.fromkeys(wanted_snaps, {}) %}
{% endif %}
{% if classic_snaps is not mapping %}
{% set classic_snaps = dict.fromkeys(classic_snaps, {}) %}
{% endif %}

{%- if packages.snaps.packages %}
  {% if wanted_snaps or classic_snaps or unwanted_snaps %}

### REQ PKGS (without this, SNAPS can fail to install/uninstall)
include:
  - packages.pkgs
  {% if req_states %}
    {% for dep in req_states %}
  - {{ dep }}
    {% endfor %}
  {% endif %}

extend:
  unwanted_pkgs:
    pkg.purged:
      - pkgs: {{ unwanted_packages | json }}

  pkg_req_pkgs:
    pkg.installed:
      - pkgs: {{ req_packages | json }}
    {% if req_states %}
      - require:
      {% for dep in req_states %}
        - sls: {{ dep }}
      {% endfor %}
    {% endif %}
      - retry: {{ packages.retry_options|json }}

{% if packages.snaps.symlink %}
{# classic confinement requires snaps under /snap or symlink from #}
{# /snap to /var/lib/snapd/snap #}
packages-snap-classic-symlink:
  file.symlink:
    - name: /snap
    - target: /var/lib/snapd/snap
    - unless: test -d /snap
    - require:
      - pkg: pkg_req_pkgs
      - pkg: unwanted_pkgs
{% endif %}

{% for snap in packages.snaps.service %}
packages-{{ snap }}-service:
  service.running:
    - name: {{ snap }}
    - enable: true
    - require:
      - pkg: pkg_req_pkgs
      - pkg: unwanted_pkgs
{% endfor %}

### SNAPS to install
{% for snap, options in wanted_snaps.items() %}
{% set _opts = options|default({}) %}
packages-snapd-{{ snap }}-wanted:
  cmd.run:
  {% if "channel" in _opts %}
    - name: snap install {{ snap }} --channel={{ _opts["channel"] }}
  {% else %}
    - name: snap install {{ snap }}
  {% endif %}
    - unless: snap list {{ snap }}
    - output_loglevel: quiet
    - require:
      - pkg: pkg_req_pkgs
      - pkg: unwanted_pkgs
    - retry: {{ packages.retry_options|json }}
{% endfor %}

### SNAPS to install in classic mode
{% for snap, options in classic_snaps.items() %}
{% set _opts = options|default({}) %}
packages-snapd-{{ snap }}-classic:
  cmd.run:
  {% if "channel" in _opts %}
    - name: snap install --classic {{ snap }} --channel={{ _opts["channel"] }}
  {% else %}
    - name: snap install --classic {{ snap }}
  {% endif %}
    - unless: snap list {{ snap }}
    - output_loglevel: quiet
    - require:
      - pkg: pkg_req_pkgs
      - pkg: unwanted_pkgs
    - retry: {{ packages.retry_options|json }}
{% endfor %}


### SNAPS to uninstall
{% for snap in unwanted_snaps %}
packages-snapd-{{ snap }}-unwanted:
  cmd.run:
    - name: snap remove {{ snap }}
    - onlyif: snap list {{ snap }}
    - output_loglevel: quiet
    - require:
      - pkg: pkg_req_pkgs
      - pkg: unwanted_pkgs
{% endfor %}

  {% endif %}
{% endif %}
