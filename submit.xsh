#!/usr/bin/env xonsh
import os
import sys
import uuid
import jinja2
import pathlib
import datetime
from pathlib import Path

from xonsh.lib.os import indir

try:
    import ruamel.yaml as yaml
except ImportError:
    try:
        import ruamel_yaml as yaml
    except ImportError:
        import yaml

name = '{}-{}'.format(
    datetime.datetime.utcnow().isoformat().replace(':', '-')[:16].lower(),
    str(uuid.uuid4()).split('-')[0]
    )

repo = 'https://github.com/conda-forge/zlib-feedstock',
jinja_env = {
    "name": name,
    "image": "condaforge/linux-anvil-comp7",
    "bucket": "conda-forge-builds",
    "config": "linux_",
    "tolerations": [],
}

repo = 'https://github.com/conda-forge/cupy-feedstock',
jinja_env = {
    "name": name,
    "image": "condaforge/linux-anvil-cuda:10.1",
    "bucket": "conda-forge-builds",
    "config": "linux_cuda_compiler_version10.1python3.7",
    "tolerations": [],
}
map_name = f"build-script-{name}"

rm -rf src
git clone @(repo) src

with indir('src'):
    # TODO: read the various config values here and use that to do something
    with indir('.ci_support'):
        config_files = gp`*.yaml`
        print("Choose a config from the following:")
        cfgs = set()
        for c in config_files:
            cfg , _= os.path.splitext(os.path.basename(c))
            if cfg.startswith('linux'):
                cfgs.add(cfg)
        cfg_map = {i + 1: cfg for i, cfg in enumerate(sorted(cfgs))}
        for i, cfg in cfg_map.items():
            print(f'{i:>4} : {cfg}')
        number = input("Chosen number :")
        if number.isnumeric():
            cfg = cfg_map[int(number)]
        else:
            if number in cfgs:
                cfg = number
            else:
                print("Invalid choice.  Exiting")
                sys.exit(1)

        with open(f"{cfg}.yaml") as fo:
            variant = yaml.safe_load(fo)
            if 'docker_image' in variant:
                print(variant['docker_image'])
                jinja_env['docker_image'] = variant['docker_image'][0]
    print("creating source archive")
    git archive HEAD -o ../src.tar


if "linux-anvil-cuda" in jinja_env['image']:
    jinja_env['tolerations'].append({
        "key": "nvidia.com/gpu"
    })
else:
    jinja_env['tolerations'].append({
        "key": "build-only"
    })
    jinja_env['tolerations'].append({
        "key": "preemptible"
    })

print(jinja_env)

for p in pathlib.Path('.').glob('*.j2'):
    template = jinja2.Template(p.read_text())
    out = Path(p.stem)
    out.write_text(template.render(**jinja_env))

dry_run = False
if not dry_run:
    kubectl create configmap @(map_name) --from-file=build_script.sh
    kubectl create configmap f"src-{name}" --from-file=src.tar
    kubectl apply -f job.yaml
