% JN Kather 2019

function doGPUworkaround()

workaroundSuccess = false;

% try N times
for i = 1:10
try
    warning off parallel:gpu:device:DeviceLibsNeedsRecompiling
    warning('on','nnet_cnn:warning:GPULowOnMemory'); % set low memory warning on
    nnet.internal.cnngpu.reluForward(1); % workaround for CUDA problem on Ubuntu
    gpuArray.eye(2)^2;                   % workaround for CUDA problem on Ubuntu
    workaroundSuccess = true;
    continue
catch
    warning('-- GPU workaround failed, try again');
    pause(2);
end
end

if workaroundSuccess
    disp('--- GPU workaround succeeded');
else
    error('GPU workaround failed after max. number of attempts');
end

end