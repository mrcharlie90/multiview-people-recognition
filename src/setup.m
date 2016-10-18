% matlab -nojvm -nodisplay -nosplash -r "setup.m"
src = pwd;
cd ../filtered-channel-features/external;
toolboxCompile;
cd(src);
cd ../toolbox/external;
toolboxCompile;
cd(src);
exit;