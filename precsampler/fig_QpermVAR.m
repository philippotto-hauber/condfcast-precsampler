% this code produces the figure fig_Qperm_VAR.pdf' and stores it in the
% figures dir. Prior to executing these lines, run simul(71) (HS sampler,
% conditional forecast) and set a breakpoint in construct_PQP.m at line 69!

highl_area = Nmis; % (N - N_c)*Nt
figure(1);
fig = gcf;
fig.PaperOrientation = 'landscape';
spy(PQP)
xlabel('')
rectangle('Position',[0 0 highl_area highl_area],...
          'FaceColor','none','EdgeColor',[0 0 0], 'LineWidth', 2)
title('$$Q_{z_{\mathcal{P}}}$$','interpreter','latex','FontSize',16)

print('../figures/fig_Qperm_VAR.pdf','-dpdf','-fillpage') ; 