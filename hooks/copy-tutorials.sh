## Copy example notebooks to home
if [ ! -d "$HOME/notebooks/Tutorials" ]; then
  mkdir -p $HOME/notebooks/Tutorials
fi

cp -r /packages/pyCAP/examples $HOME/notebooks/Tutorials/pyCAP
cp -r /packages/scdmsPyTools/demo $HOME/notebooks/Tutorials/scdmsPyTools
cp -r /packages/tutorials $HOME/notebooks/Tutorials/Analysis
