function outDirs = overrideBaseDir(inDirs,origBaseDir,overrideDirs)

    warning('--- will override base directories for multiple input project ... be careful!');
    disp('---- original tile input directories are:')
    inDirs'
    
    sanityCheck(numel(inDirs)==numel(overrideDirs),'correct number of overrideDirs'); 
    
    outDirs = inDirs; % preallocate
    for i=1:numel(inDirs)
        outDirs{i} = strrep(inDirs{i},origBaseDir,overrideDirs{i});
    end
    
    disp('---- new tile input directories are:')
    outDirs'
    
end