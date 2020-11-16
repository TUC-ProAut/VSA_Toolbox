%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of VSA_Toolbox.                                       %
%                                                                         %
% Copyright (C) 2020 Chair of Automation Technology / TU Chemnitz         %
% For more information see https://www.tu-chemnitz.de/etit/proaut/vsa     %
%                                                                         %
% VSA_Toolbox is free software: you can redistribute it and/or modify     %
% it under the terms of the GNU General Public License as published by    %
% the Free Software Foundation, either version 3 of the License, or       %
% (at your option) any later version.                                     %
%                                                                         %
% VSA_Toolbox is distributed in the hope that it will be useful,          %
% but WITHOUT ANY WARRANTY; without even the implied warranty of          %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           %
% GNU General Public License for more details.                            %
%                                                                         %
% You should have received a copy of the GNU General Public License       %
% along with Foobar.  If not, see <http://www.gnu.org/licenses/>.         %
%                                                                         %
% Author: Kenny Schlegel (kenny.schlegel@etit.tu-chemnitz.de)             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [acc, VSA] = language_recognition(vsa, dim, num_ngrams)
%   perform the language recognition experiment 
%   
%   INPUT:
%       VSA:                VSA object (vsa_env)
%       dim:                Dimesnion
%       num_ngrams:         number of letters in ngram
%   OUTPUT:
%       acc:                accuracy
%       VSA:                VSA object (vsa_env)
%
% scken, 2020


% load data from TUC server
workspace_path = mfilename('fullpath');
workspace_path = workspace_path(1:find(workspace_path == '/',1,'last'));

if isdir([workspace_path '../datasets/lang_rec'])==0
    mkdir([workspace_path '../datasets']);
    websave([workspace_path '../datasets/download'], 'https://tuc.cloud/index.php/s/skMKBzWE6RztDjF/download');
    unzip([workspace_path '../datasets/download'],[workspace_path '../datasets/lang_rec']);
    delete([workspace_path '../datasets/download']);
end
 
dataset_path_train = [workspace_path '../datasets/lang_rec/N-grams/training'];
dataset_path_test = [workspace_path '../datasets/lang_rec/N-grams/testing'];



files = dir(dataset_path_train);

VSA = vsa_env('vsa',vsa,'dim',dim, 'max_density', 0.5);

% create bag of characters 
chars_item_memory = VSA.add_vector('num',10000,'add_item',0);

% create n-grams sequence encodings 
seq_item_memory = VSA.add_vector('num',num_ngrams,'add_item',0);

data_size = 0.1;

%% training

vector_buffer = [];
name_buffer = {};

fprintf('\n Training... Computation Progress: %3d%%\n',0);
parfor id=3:size(files,1)
    file_name = files(id,:);
    prog = id/(size(files,1));
    fprintf(1,'\b\b\b\b%3.0f%%',prog*100);
    sentences = readtable([dataset_path_train '/' file_name.name '/' file_name.name '.txt'],'Format','%s','ReadVariableNames',0);   

    text = [sentences.Var1{1:data_size*size(sentences.Var1,1)}];
    buffer = [];
    
    for c=num_ngrams+1:numel(text)
        ngram = operations.getNgram(VSA, text(c-num_ngrams:c-1), chars_item_memory, seq_item_memory);
        % accumulate all vectors without normalization
        buffer = VSA.bundle(buffer,ngram,0);
    end
    
    % normalize vector into specific range
    language_vector = VSA.bundle(buffer,[]);
    
    vector_buffer(:,id-2) = language_vector;
    name_buffer{id-2,1} = file_name.name(1:3);
end

VSA.add_vector('vec', vector_buffer, 'name', name_buffer);
    
%% testing   

files = dir(dataset_path_test);
correct = 0;
total = 0;

fprintf('\n Testing... Computation Progress: %3d%%\n',0);
parfor i=3:size(files,1)
    file_name = files(i,:);
    prog = i/(size(files,1));
    fprintf(1,'\b\b\b\b%3.0f%%',prog*100);
    sentences = readtable([dataset_path_test '/' file_name.name '/' file_name.name '.txt'],'Format','%s','ReadVariableNames',0);   

    currentLabel = file_name.name;
    
    % create n-grams language vector
    for s=1:floor(size(sentences,1)*data_size)
        text = [sentences.Var1{s}];
        char_codes = double(text);
        buffer = [];

        % create ngrams
        for c=num_ngrams+1:numel(text)
            %create ngrams
            ngram = operations.getNgram(VSA, text(c-num_ngrams:c-1), chars_item_memory, seq_item_memory);
            % accumulate all vectors without normalization
            buffer = VSA.bundle(buffer,ngram,0);
        end

        % normalize vector into specific range
        language_vector = VSA.bundle(buffer,[]);
        
        [~, lang, ~] = VSA.find_k_nearest(language_vector,1);

        if lang{1} == currentLabel
            correct = correct +1;
        end

        total = total +1;
    end
end

acc=correct/total;

fprintf('\n')

end

