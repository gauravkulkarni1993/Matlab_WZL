function FilePathNew = deletePathParts(FilePath,idx)
% TODO: add description


% allocate memory
FilePathNew = cell(size(FilePath));
% loop
% tic
for i = 1:size(FilePath,1)
    % split path parts
    FilePathNew{i} = deletePathParts_sgl(FilePath{i},idx);
end
% toc

% tic
% FilePathNew2 = cellfun(@(x)deletePathParts_sgl(x,idx),FilePath,'UniformOutput',false);
% toc
% equal speed, CPU load, & memory

end

function FilePathNew = deletePathParts_sgl(FilePath,idx)

Path_parts = strsplit(FilePath,filesep);

FilePathNew = fullfile(Path_parts{idx:end});
end