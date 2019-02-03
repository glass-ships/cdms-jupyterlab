## Create or clear Tutorials dir, copy examples and tutorials

if [ ! -d "$HOME/notebooks/Tutorials" ]; then
  mkdir -p $HOME/notebooks/Tutorials
elif [ -d "$HOME/notebooks/Tutorials" ]; then
  rm -rf $HOME/notebooks/Tutorials/*
fi

mkdir $HOME/notebooks/Tutorials/pyCAP && cp -r /packages/pyCAP/examples/* $HOME/notebooks/Tutorials/pyCAP
mkdir $HOME/notebooks/Tutorials/scdmsPyTools && cp -r /packages/scdmsPyTools/demo/* $HOME/notebooks/Tutorials/scdmsPyTools
mkdir $HOME/notebooks/Tutorials/Analysis && cp -r /packages/tutorials/* $HOME/notebooks/Tutorials/Analysis
