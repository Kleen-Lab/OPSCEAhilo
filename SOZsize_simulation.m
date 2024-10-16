function SOZsize_simulation_video

dims=3; 
r_SOZs=18:.1:33; 
iedist_LD=10;
iedist_HD=5;
iedist_HHD=1;
XYZshift=[2 5 8];
color_SOZ= [1 1 0];
color_LD=[1 .3 1];
color_HD=[.3 .3 1];
color_HHD=[.3 1 .3];

xl=[2e4 1.52e5];
yl1=[  0  60000]; %volume in mm^3
yl2=[-30     90]; %percent change
nr=length(r_SOZs);

sp_LD=[2,3,1; 2,3,2];
sp_HD=[2,3,4; 2,3,5];
s_vol_LD=nan(nr,1);
s_vol_HD=nan(nr,1);
s_vol_HHD=nan(nr,1);
e_vol_LD=nan(nr,1);
e_vol_HD=nan(nr,1);
e_vol_HHD=nan(nr,1);

figure('color','w','position',[100 4 1171 736])
rot8=215;
F=[];
for i=1:length(r_SOZs)
    tic
    subplot(10,1,1:9) %clear all subplots, fresh frame
    % low density (LD)
    [s_vol_LD(i),e_vol_LD(i),F]=SOZsize_simulation(dims,r_SOZs(i),iedist_LD,XYZshift,sp_LD,color_SOZ,color_LD,0,i==1,F);
    title({['LD estimated volume: ' num2str(round(e_vol_LD(i))) 'mm^3'],''}); 
    
    % high density (HD)
    [s_vol_HD(i),e_vol_HD(i)]=SOZsize_simulation(dims,r_SOZs(i),iedist_HD,XYZshift,sp_HD,color_SOZ,color_HD,0);
    title({['HD estimated volume: ' num2str(round(e_vol_HD(i))) 'mm^3'],''}); 

    % very high density (HD)
    figure(2); set(gcf,'color','w','Position',[1 4 1171 736]); subplot(10,1,1:9) %clear all subplots
    [s_vol_HHD(i),e_vol_HHD(i)]=SOZsize_simulation(dims,r_SOZs(i),iedist_HHD,XYZshift,sp_HD,color_SOZ,color_HD,0);
    title({['HHD estimated volume: ' num2str(round(e_vol_HHD(i))) 'mm^3'],''}); 
    subplot(2,3,4); title({'HHD condition',['SOZ true volume: ' num2str(round(s_vol_HHD(i))) 'mm^3'],['radius: ' num2str(r_SOZs(i)) 'mm'],''}); 
    figure(1)

    subplot(2,3,1); title({'LD condition',['SOZ true volume: ' num2str(round(s_vol_LD(i))) 'mm^3'],['radius: ' num2str(r_SOZs(i)) 'mm'],''}); 
    subplot(2,3,4); title({'HD condition',['SOZ true volume: ' num2str(round(s_vol_HD(i))) 'mm^3'],['radius: ' num2str(r_SOZs(i)) 'mm'],''}); 
    
    subplot(8,3,[9:3:18]); 
    plot(s_vol_LD(1:i),e_vol_LD(1:i),'.-','linewidth',3,'color',color_LD*.7) %estimate SOZ with LD
    hold on
    grid on
    plot(s_vol_LD(1:i),e_vol_HD(1:i),'.-','linewidth',3,'color',color_HD*.7) %estimate SOZ with HD
    plot(s_vol_LD(1:i),e_vol_HHD(1:i),'.-','linewidth',3,'color',color_HHD*.7) %estimate SOZ with HD
    
    plot([1 max([xl yl1])],[1 max([xl yl1])],'-','linewidth',.5,'color',[.1 .1 .1]) %marks line where true = estimated (theoretical)
    plot(s_vol_LD(1:i),s_vol_LD(1:i),'.-','linewidth',3,'color',[.1 .1 .1]) %estimate SOZ with HD
    xlim(xl)
    ylim(yl1); ylabel('Estimated volume (mm^3)')
    text(3e4,3.5e4,'Perfect estimate','Rotation',69)
    legend({[num2str(iedist_LD) 'mm'],[num2str(iedist_HD) 'mm'],[num2str(iedist_HHD) 'mm']},'Location','southeast')
    
    subplot(4,3,12)
    plot(s_vol_LD(1:i),(e_vol_HD (1:i)-e_vol_LD(1:i))./e_vol_LD(1:i)*100,'.-','linewidth',4,'color',color_HD*.8) %estimate SOZ with LD
    hold on
    grid on
    plot(s_vol_LD(1:i),(e_vol_HHD(1:i)-e_vol_LD(1:i))./e_vol_LD(1:i)*100,'.-','linewidth',3,'color',color_HHD*.8) %estimate SOZ with LD
    plot(xl,[0 0],'k-','linewidth',2) 
    
    xlabel('SOZ true volume (mm^3)')
    ylabel({['HD volume % difference'],['relative to LD (' num2str(iedist_LD) 'mm)']})
    xlim(xl)
    ylim(yl2)
    legend({[num2str(iedist_HD) 'mm'],[num2str(iedist_HHD) 'mm']},'Location','northeast')

    for s=[1 2 4 5];
        subplot(2,3,s);
        set(gca,'Clipping','off')
        view(rot8,20);
    end
    rot8=rot8+.2;
    
    F(length(F)+1)=getframe(gcf); 
    toc
end

vidfn = '~/Desktop/Video1';
v=VideoWriter(vidfn,'MPEG-4');
v.FrameRate = 10;
open(v);
writeVideo(v,F);
close(v);


