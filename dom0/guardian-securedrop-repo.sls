{% import_json "sd/config.json" as d %}

install-apt-transport:
  pkg.installed:
    - pkgs:
      - apt-transport-s3


/etc/apt/s3auth.conf:
  file.managed:
    - name: /etc/apt/s3auth.conf
    - source: salt://sd/s3auth.conf
    - user: root
    - group: root

add guardian securedrop repo:
  pkgrepo.managed:
    - name: "deb s3://{{ d.guardian_securedrop_apt_bucket }}/ bullseye main"
    - key_url: salt://sd/guardian-securedrop-release.asc
    - humanname: Guardian securedrop PPA

