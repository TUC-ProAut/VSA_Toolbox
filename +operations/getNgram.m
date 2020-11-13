function ngram = getNgram(VSA, keys, char_item_memory, seq_item_memory)

key_codes = double(keys);
num_ngrams = length(key_codes);
%create ngrams
ngram = VSA.permute(char_item_memory(:,key_codes(1)));
for i=2:num_ngrams
    ngram = VSA.bind(ngram,VSA.permute(char_item_memory(:,key_codes(i)),i));
end

end

