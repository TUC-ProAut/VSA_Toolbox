function sim_matrix = complexSim(v1,v2)
% compute the similarity between vectors of angles (from complex numbers
% --> FHRR)

sim_matrix = zeros(size(v1,1),size(v2,1));

for i=1:size(v1,1)
    sim_matrix(i,:)=sum(cos(v1(i,:)-v2),2)/size(v1,2);
end


end