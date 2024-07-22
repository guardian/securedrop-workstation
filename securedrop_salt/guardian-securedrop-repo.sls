{% import_json "securedrop_salt/config.json" as d %}

install-apt-transport:
  pkg.installed:
    - pkgs:
      - apt-transport-s3


/etc/apt/s3auth.conf:
  file.managed:
    - name: /etc/apt/s3auth.conf
    - source: "salt://s3auth.conf.j2"
    - template: jinja
    - context:
        access_key_id: {{ d.guardian.aws.access_key_id }}
        secret_access_key: {{ d.guardian.aws.secret_access_key }}
        region: {{ d.guardian.aws.region }}
    - user: root
    - group: root

add guardian securedrop repo:
  pkgrepo.managed:
    - name: "deb s3://{{ d.guardian.apt_repo_bucket }}/ bullseye main"
    - key_url: "salt://sd/sd-workstation/{{ d.guardian.signing_key_filename }}"
    - humanname: Guardian securedrop PPA

