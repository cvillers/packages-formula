# -*- coding: utf-8 -*-
# vim: ft=yaml
---
# Dependency (node)
node:
  version: 12.16.1-1nodesource1
  install_from_ppa: true
  ppa:
    repository_url: https://deb.nodesource.com/node_12.x

packages:
  pkgs:
    # A dict of "package: version" pairs:
    # held:
    #   alien: 8.95
    #   iotop: 0.6-2

    # Alternativelly, held packages can also be specified as a list with
    # no versions. In this case, the package will be held in the installed
    # version.
    held:
      - alien
      - iotop
    wanted:
      - git
      - less
      - bc
      - curl
      - fail2ban
    unwanted:
      - avahi-daemon
    required:
      pkgs:
        - wget
        - git

  pips:
    required:
      pkgs:
        # Pillar parameters have precedence so, if you add a package here, you
        # should also add the python pip package you want. Otherwise, the formula
        # will take care of getting it if needed.
        - libpython2.7-dev
        - python-pip
    wanted:
      - dxpy
      - attrs
    unwanted:
      - campbel
      - reverse_geocode
      - indy-crypto
    config:
      global:
        timeout: 120
        default-timeout: 120
        # proxy: http://proxy.example.com:3128

  gems:
    wanted:
      - progressbar
      - minitest
    unwanted:
      - diff-lcs
      - kitchen-vagrant
      - kwalify

  snaps:
    wanted:
      hello-world:
    classic:
      test-snapd-hello-classic:
    unwanted:
      - bare

  # yamllint disable rule:line-length
  npms:
    dir: /home/kitchen/npms   # The target directory in which to install the package, or None for global installation
    user: kitchen             # The user to run NPM with (and to assign to `dir`)
    group: kitchen            # The group to assign to `dir`
    mode: '0755'              # The permissions to assign to `dir`
    # registry: None          # The NPM registry from which to install the package
    # env: None               # A list of environment variables to be set prior to execution
    # force_reinstall: False  # Install the package even if it is already installed
    required:
      states:
        - node.package.install
    wanted:
      # Valid formats:
      #
      # @google-cloud/bigquery@^0.9.6
      # @foobar
      # buffer-equal-constant-time@1.0.1
      # coffee-script
      # You need to quote the package if it starts with '@'
      - '@davidodio/hello@2.3.0'
      - hello-world-npm
      - sax
      - coffee-script@1.0.1
    unwanted:
      - gist
  # yamllint enable rule:line-length

  archives:
    wanted:
      terminator:
        dest: /usr/local/terminator/
        options: '--strip-components=1'  # recommended option, but beware tarbombs
        dl:
          format: tar
          # yamllint disable rule:line-length
          source: https://launchpad.net/terminator/gtk3/1.91/+download/terminator-1.91.tar.gz
          # hashurl: https://launchpad.net/terminator/gtk3/1.91/+download/terminator-1.91.tar.gz/+md5
          # yamllint enable rule:line-length
          hashsum: md5=2eed999d7a41f2e18eaa511bbbf80f58
      phantomjs:
        dest: /usr/local/src/  # beware tarbombs
        user: root
        mode: '0700'
        dl:
          format: tar
          # yamllint disable rule:line-length
          source: https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
          hashsum: md5=1c947d57fce2f21ce0b43fe2ed7cd361
          # yamllint enable rule:line-length
      blockbox:
        dest: /usr/local/src/
        dl:
          format: raw
          # yamllint disable-line rule:line-length
          source: https://raw.githubusercontent.com/openstack/cinder/master/contrib/block-box/docker-compose.yml
          hashsum: 1751f8e4f6b4cddd8c4843a0f4473274
      kubectl:
        dest: /usr/local/bin
        dl:
          format: bin
          # yamllint disable-line rule:line-length
          source: https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/darwin/amd64/kubectl
    unwanted:
      - /usr/local/boring_archive_software

  remote_pkgs:
    zoom: 'https://zoom.us/client/latest/zoom_amd64.deb'

  # Override the default setting to prevent wasteful delays in Travis
  retry_options:
    attempts: 1
