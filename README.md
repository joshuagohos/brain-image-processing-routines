# Brain Image Processing Routines
*Updated 20260103 by Josh Goh*

## OVERVIEW
Currently, 
- This repository contains Bash and Matlab scripts for scaling brain image processing routines using control pipelines.
- Brain image preprocessing and statistical analysis routines are primarily configured to use SPM25.
- Bash shell scripts are configured for Ubuntu or CentOS Linux operating systems.

The usage mode is to pass Matlab routines in Bash shell script wrappers, and call these routines in Bash shell script pipelines. This allows for,
- Flexible control of routine order 
- Capacity to integrate routines based on other programming environments (e.g. Python, R).

## DEPENDENCIES
*Note: For Brain and Mind Lab members, these are all already configured in our lab servers. See [Brain and Mind Lab's Setup Server Environment Gitlab](https://gitlab.com/brain-and-mind-lab/servers/setup-server-environment)*

**1. MricroGL**
- This is needed for the dicom conversion tool (dcm2niix).
- This needs to be installed with dcm2niix (mricrogl; optional) in the system search path.
- Here is a sample script to install MricroGL in a manner that the pipelines here can use (as at 2026/12/18).
```
cd ~/Downloads
wget https://github.com/rordenlab/MRIcroGL/releases/download/v1.2.20220720/MRIcroGL_linux.zip
unzip MRIcroGL_linux.zip
sudo cp -rf MRIcroGL /opt/
cd /usr/local/bin
sudo ln -s /opt/MRIcroGL/MRIcroGL mricrogl
sudo ln -s /opt/MRIcroGL/Resources/dcm2niix dcm2niix
```

**2. Matlab**
- This should be downloaded from [MathWorks](https://www.mathworks.com) using your Mathworks account and installed as instructed on their website.
- The matlab installation must include the image processing toolbox and the statistics and machine learning toolbox.
- The 'matlab' function then needs to be in the system search path.
- Here is a sample installation script after the installation zip file has been downloaded and unzipped (e.g. to the ~/Downloads/matlab_R2025b_Linux folder).
```
## Download Matlab installer (e.g. ver. R2025b) from mathworks.com (requires account), unzip
cd ~/Downloads/matlab_R2025b_Linux
xhost +SI:localuser:root
sudo -H ./install
xhost -SI:localuser:root 
cd /usr/local/bin
sudo ln -s /usr/local/MATLAB/2025b/bin/matlab
```

**3. SPM25**
- This should be installed and set up to be in the user-level Matlab's search path.
- Here is a sample installation script (as at 2026/12/18).
```
cd ~/Downloads
wget https://github.com/spm/spm/releases/download/25.01.02/spm_25.01.02.zip
unzip spm_25.01.02.zip
sudo cp -rf ~/Downloads/spm /opt/
echo "% SPM Setup" >> ~/Documents/MATLAB/startup.m
echo "addpath /opt/spm" >> ~/Documents/MATLAB/startup.m
echo "warning('off', 'MATLAB:class:LoadWarning');" >> ~/Documents/MATLAB/startup.m
```

- The TAPAS-PhysIO toolbox is also required.
- Here is a sample installation script (as at 2026/12/21).
```
cd ~/Downloads
wget https://github.com/ComputationalPsychiatry/PhysIO/releases/download/v9.0.3/PhysIO-v9.0.3.zip
unzip PhysIO-v9.0.3.zip
sudo mkdir -p /opt/spm/toolbox/PhysIO
sudo cp -rf PhysIO-9.0.3/code/* /opt/spm/toolbox/PhysIO/
```

**4. FSL**
- This should be installed at the system level.
- Here is a sample installation script (as at 2026/12/18).
```
sudo apt update
sudo apt install -y python3 python3-pip python3-venv curl libegl1 libgl1 libgtk-3-0 libnotify4 libpcre2-32-0 libsdl2-2.0-0 libsm6 libxxf86vm1
curl -L -o /tmp/fslinstaller.py https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
sudo python3 /tmp/fslinstaller.py -d /usr/local/fsl -q
sudo bash -c 'echo "# FSL Configuration Script" >> /etc/profile.d/fsl.sh'
sudo bash -c 'echo "export FSLDIR=/usr/local/fsl" >> /etc/profile.d/fsl.sh'
sudo bash -c 'echo ". /usr/local/fsl/etc/fslconf/fsl.sh" >> /etc/profile.d/fsl.sh'
sudo chmod +x /etc/profile.d/fsl.sh
```

**5. AFNI**
- This should be installed at the system level.
- Here is a sample installation script (as at 2026/12/18).
```
sudo apt update
sudo apt install tcsh
sudo mkdir /usr/local/afni
cd /usr/local/afni
sudo curl -O https://afni.nimh.nih.gov/pub/dist/tgz/linux_ubuntu_24_64.tgz
sudo tar -xvzf linux_ubuntu_24_64.tgz
sudo rm linux_ubuntu_24_64.tgz
sudo mv /usr/local/afni/linux_ubuntu_24_64 /usr/local/afni/abin
cat << 'EOF' | sudo tee /etc/profile.d/afni.sh
#!/bin/sh
# Set AFNI system-wide path
export AFNI_DIR=/usr/local/afni
export AFNI_PLUGINPATH=/usr/local/afni/abin
export PATH=${AFNI_DIR}/abin:${PATH}
EOF
cat << 'EOF' | sudo tee /etc/profile.d/afni.csh
#!/bin/csh
# Set AFNI system-wide path
setenv AFNI_DIR /usr/local/afni
setenv AFNI_PLUGINPATH /usr/local/afni/abin
set path = ( /usr/local/afni/abin $path )
EOF
sudo chmod +x /etc/profile.d/afni.sh
sudo chmod +x /etc/profile.d/afni.csh
cd /usr/local/afni/abin
sudo env PATH=.:$PATH ./@afni_R_package_install -afni -shiny
afni_system_check.py -check_all 
cd /usr/local/afni/abin
sudo env PATH=.:$PATH ./@afni_R_package_install -custom "gamm4 corrplot metafor"
sudo cp /usr/local/afni/abin/AFNI.afnirc /etc/skel/.afnirc
cp /usr/local/afni/abin/AFNI.afnirc ~/.afnirc
cd ~
suma -update_env
apsearch -update_all_afni_help
```

**6. Freesurfer**
- This should be installed at the system level.
- Here is a sample installation script (as at 2026/12/18).
```
cd ~/Downloads
sudo apt update
sudo apt install tcsh 
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/8.1.0/freesurfer_ubuntu22-8.1.0_amd64.deb
# Get license from https://surfer.nmr.mgh.harvard.edu/registration.html
mkdir fs-temp
dpkg-deb -R freesurfer_ubuntu22-8.1.0_amd64.deb fs-temp
sudo mkdir -p /usr/local/freesurfer
sudo mv fs-temp/usr/local/freesurfer/8.1.0 /usr/local/freesurfer/
rm -rf fs-temp
sudo cp license.txt /usr/local/freesurfer/8.1.0/
wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu70_70.1-2_amd64.deb
sudo dpkg -i libicu70_70.1-2_amd64.deb
sudo bash -c 'echo "export FREESURFER_HOME=/usr/local/freesurfer/8.1.0" >> /etc/profile.d/freesurfer.sh'
sudo bash -c 'echo "source /usr/local/freesurfer/8.1.0/SetUpFreeSurfer.sh" >> /etc/profile.d/freesurfer.sh'
sudo chmod +x /etc/profile.d/freesurfer.sh
```

## INSTALLATION OF ROUTINES, SYMBOLIC LINKS, AND PIPELINES 
**Ubuntu, CentOS (Linux)**
1. Download this repository to your local home path Downloads folder (e.g. /home/user/Downloads)
```
cd ~/Downloads
wget https://github.com/joshuagohos/brain-image-processing-routines/archive/refs/heads/main.zip
```

2. Unzip the downloaded zip file.
```
unzip main.zip
```
This will results in a folder named brain-image-processing-routines. The folder contains the following:
```
brain-image-processing-routines
├── LICENSE
├── README.md
├── bin
├── pipelines
└── routines
```
- bin: symbolic links pointing to shell scripts in the routines directory. The contents in this folder should be copied to /usr/local/bin/
- pipelines: Control shell scripts that call routines scripts in the routine directory. These pipeline and specs (sub-folder) scripts should be placed in specific project code or script folders and modified for use accordingly.
- routines: Bash shell wrappers scripts passing brain processing functions into respective coding environments.

3. Copy the routines folder to /opt/brain-image-processing-routines/ and make executable.
```
sudo mv ~/Downloads/brain-image-processing-routines-main ~/Downloads/brain-image-processing-routines
sudo cp -rf ~/Downloads/brain-image-processing-routines /opt/
sudo chmod -R +x /opt/brain-image-processing-routines/routines/*
```

4. Make read/write/executable and copy (using rsync) the contents (symbolic links) of the bin folder to /usr/local/bin/.
```
sudo chmod +rwx /opt/brain-image-processing-routines/bin/*
sudo rsync -azvh /opt/brain-image-processing-routines/bin/* /usr/local/bin/
```

# Usage
Configure the pipeline scripts in brain-image-processing-routines/pipelines as needed and run. For example, after. configuring pipeline.sh, run the following.
```
cd /path/to/project/brain-image-processing-routines/pipelines
./pipeline.sh
```

