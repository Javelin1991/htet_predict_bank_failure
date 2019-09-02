input_0 = ovarian_g4_input(1:63,:);
%label_0 = ovarian_g1_target(1:63);
label_0 = zeros(63,1);

input_1 = ovarian_g4_input(64:107,:);
%label_1 = ovarian_g1_target(64:107);
label_1 = ones(44,1);

cv_g4{1}.input = [ input_1(1:12,:); input_0(1:18,:);input_0(19:end,:); input_1(13:end,:)];
cv_g4{1}.label = [ label_1(1:12); label_0(1:18); label_0(19:end); label_1(13:end)];

cv_g4{2}.input = [ input_1(13:24,:); input_0(19:36,:); input_0(1:18,:); input_0(37:end,:); input_1(1:12,:); input_1(25:end,:)];
cv_g4{2}.label = [ label_1(13:24); label_0(19:36); label_0(1:18); label_0(37:end); label_1(1:12); label_1(25:end)];

cv_g4{3}.input = [ input_1(25:36,:); input_0(37:54,:); input_0(1:36,:); input_0(55:end,:); input_1(1:24,:); input_1(37:end,:)];
cv_g4{3}.label = [ label_1(25:36); label_0(37:54); label_0(1:36); label_0(55:end); label_1(1:24); label_1(37:end)];

cv_g4{4}.input = [ input_1(25:36,:); input_0(37:54,:); input_1(1:24,:); input_1(37:end,:); input_0(1:36,:); input_0(55:end,:)];
cv_g4{4}.label = [ label_1(25:36); label_0(37:54); label_1(1:24); label_1(37:end); label_0(1:36); label_0(55:end)];
