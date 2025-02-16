#!/bin/bash
#
# SPDX-License-Identifier: MIT
#

# Build it
runtime=python3
python_ver=3.11
python${python_ver} -m venv python3

# Dont need these
for delete_me in python${python_ver} activate activate.csh activate.fish Activate.ps1 python ; do
    rm ./${runtime}/bin/${delete_me}
done

# Nor this.
rm ${runtime}/pyvenv.cfg

# Copy python binary
cp `which python${python_ver}` ${runtime}/bin/python${python_ver}

# Strip it.
strip ${runtime}/bin/python${python_ver}
find ${runtime}/lib -iname '**.so*' -exec strip {} \;

# Patch scripts
for script in easy_install pip pip3 pip${python_ver}  ; do
    sed -i 's/#!\/.*\/bin\/python.*/#\!\/usr\/bin\/env python3/g' ./${runtime}/bin/${script}
done

# Copy python libraries
cp -R "/usr/local/lib/python${python_ver}/"* "./${runtime}/lib/python${python_ver}"
find ./${runtime} -iname "__pycache__" -exec rm -rf {} \;

cat << __END__ > ${runtime}/bin/activate
#!/bin/bash

PYTHONHOME="\$HOME/${runtime}"
PATH="\$HOME/${runtime}/bin:\$PATH"
LD_LIBRARY_PATH="\$HOME/${runtime}/lib:\$LD_LIBRARY_PATH"

__END__

chmod +x ${runtime}/bin/activate

cd ${runtime}

mksquashfs * ../python_3.11.squashfs

cd ..

