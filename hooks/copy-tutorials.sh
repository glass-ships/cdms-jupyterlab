## Copy example notebooks to home
if [ ! -d "$HOME/notebooks/Tutorials" ]; then
  mkdir -p $HOME/notebooks/Tutorials
fi

rm -rf $HOME/notebooks/Tutorials/*

mkdir $HOME/notebooks/Tutorials/pyCAP && cp -r /packages/pyCAP/examples/* $HOME/notebooks/Tutorials/pyCAP
mkdir $HOME/notebooks/Tutorials/scdmsPyTools && cp -r /packages/scdmsPyTools/demo/* $HOME/notebooks/Tutorials/scdmsPyTools
mkdir $HOME/notebooks/Tutorials/Analysis && cp -r /packages/tutorials/* $HOME/notebooks/Tutorials/Analysis
