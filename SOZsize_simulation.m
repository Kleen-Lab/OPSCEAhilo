function [s_vol,e_vol,F]=SOZsize_simulation(dims,r,iedist,XYZshift,sp,color_s,color_e,newfig,initialframe,F)
% This function simulates what an epileptologist would determine as the SOZ
% extent based on electrodes that show seizure activity (i.e. in the SOZ)
% compared to a true (simulated) SOZ. 

% Procedure:
%    1. Creates a simulated SOZ in 3D SEEG
%    2. Checks which of the electrodes with coordinates inside that sphere 
%    and computes their "convex hull" (smallest shape/polygon that fits
%    all points within its boundary) for them.
%    3. Calculates volume of the sphere (true SOZ) and the convex hull
%    (assumed SOZ based on within-sphere electrodes [red dots]). 

if ~exist('dims','var') || isempty(dims); dims=3; end % number of dimensions (3 to simulate SEEG/multiple depths)
if ~exist('r'   ,'var') || isempty(r); r=1;    end % radius in mm
if ~exist('iedist','var') || isempty(iedist); iedist=5; end % inter-electrode distance in mm
if ~exist('XYZshift','var') || isempty(XYZshift); XYZshift=[0 0 0]; end % show in figure(s)
if ~exist('sp','var') || isempty(sp); sp=[1 2 1;1 2 2]; end % specifies the two subplots to show the true (1st row) and estimated (2nd row) SOZ plots
if ~exist('color_s','var') || isempty(color_s); color_s=[1 1 0]; end %sphere (true SOZ) color
if ~exist('color_e','var') || isempty(color_e); color_e=[1 0 1]; end %estimated SOZ color
if ~exist('initialframe','var') || isempty(color_e); initialframe=0; end

ecolor=[0 0 0]; % color of depth electrodes (all)
eSOZcolor=[1 0 0]; % color of depth electrodes in SOZ
depthcolor=[.7 .7 .7]; % color of depth probe shaft
nverts=50; % number of vertices in the sphere (true SOZ)
s_alpha=.6; %sphere (true SOZ) transparency
w=5; % zoom out a bit, in mm

if dims==3
    
    % create sphere vertices, and scale to radius specified
    [sX,sY,sZ] = sphere(nverts);
    sX=sX*r; sX=sX-40;
    sY=sY*r;
    sZ=sZ*r;
    sXYZ = unique([sX(:) sY(:) sZ(:)],'rows');
    sXYZ(:,1)=sXYZ(:,1)+XYZshift(1);
    sXYZ(:,2)=sXYZ(:,2)+XYZshift(2);
    sXYZ(:,3)=sXYZ(:,3)+XYZshift(3);
    % create convex hull of the 3D points, for the sphere (true SOZ)
    [sk,s_vol] = convhulln(sXYZ); 
        s_volume = volume(alphaShape(sXYZ));
    
    

    if iedist==5
        nch=10;
    elseif iedist==10
        nch=5; 
    else; disp('Note: not typical spacing for depths')
        nch=ceil(45/iedist);
    end
    coverage=iedist*(nch-1); % total length of depth in mm
    n_mm=20; % spacing (in mm) between depths
    
    % create first depth
    depthXs=-coverage/2:iedist:coverage/2;
    ncd=length(depthXs); %number of channels per depth

    % replicate, to 9 depth probes

    eX=repmat(depthXs,1,9);
    if iedist==5; eX=eX+2.5; end
    eX=eX-40; 
    eY=       [-ones(1,ncd*3) 0*ones(1,ncd*3) ones(1,ncd*3)  ]; % space out 9 depths
      eY=eY*n_mm; %multiply by number of centimeters between parallel depths
    eZ=repmat([-ones(1,ncd)   0*ones(1,ncd)   ones(1,ncd)],1,3);
      eZ=eZ*n_mm; %multiply by number of centimeters between parallel depths
    eXYZ=[eX' eY' eZ'];
    
    % Identify which electrodes are in the true SOZ (sphere volume)
    einSOZ = inhull(eXYZ,sXYZ);%,tess,tol);
    % create convex hull of the 3D points, for the interpreted SOZ
    [ek,e_vol] = convhulln(eXYZ(einSOZ,:)); 
        e_volume = volume(alphaShape(eXYZ(einSOZ,:)));
    
    
    
    if sp %plot sphere
      if newfig; figure('color','w')
      end
      


      if sp(1,1)>0 % gives option to plot true SOZ (e.g. if doing subplots for a movie)
        subplot(sp(1,1),sp(1,2),sp(1,3))
        plot3(eXYZ(:,1),eXYZ(:,2),eXYZ(:,3),'.','color',ecolor,'markersize',20); % plot all electrodes
        hold on
        plot3(eXYZ(einSOZ,1),eXYZ(einSOZ,2),eXYZ(einSOZ,3),'.','color',eSOZcolor,'markersize',16); % color electrodes that are in the true SOZ
        xlabel('X'); ylabel('Y'); zlabel('Z');
        grid on
        % connecting lines to visualize the 9 depths
        chidx=1:nch;
        for i=1:9
            plot3(eXYZ(chidx,1),eXYZ(chidx,2),eXYZ(chidx,3),'-','color',depthcolor,'LineWidth',2); 
            chidx=chidx+nch;
        end
        % plot sphere (true SOZ)
        trisurf(sk,sXYZ(:,1),sXYZ(:,2),sXYZ(:,3))
        colormap(gca,color_s); 
        alpha(s_alpha); 
        shading flat; 
        lightsout; 
        litebrain('sal',1)
        %litebrain('saallll',0)
        view(215,20)
        lighting phong
        axis equal
        axis([min(eXYZ(:,1))-w max(eXYZ(:,1))+w   min(eXYZ(:,2))-w max(eXYZ(:,2))+w   min(eXYZ(:,3))-w max(eXYZ(:,3))+w])
      end

        subplot(sp(2,1),sp(2,2),sp(2,3))
        plot3(eXYZ(:,1),eXYZ(:,2),eXYZ(:,3),'.','color',ecolor,'markersize',20); % plot all electrodes
        hold on
        plot3(eXYZ(einSOZ,1),eXYZ(einSOZ,2),eXYZ(einSOZ,3),'.','color',eSOZcolor,'markersize',14); % color electrodes that are in the true SOZ
        xlabel('X'); ylabel('Y'); zlabel('Z');
        grid on
        % connecting lines to visualize the 9 depths
        chidx=1:nch;
        for i=1:9
            plot3(eXYZ(chidx,1),eXYZ(chidx,2),eXYZ(chidx,3),'-','color',depthcolor,'LineWidth',2); 
            chidx=chidx+nch;
        end
        % plot sphere (true SOZ)
        trisurf(ek,eXYZ(einSOZ,1),eXYZ(einSOZ,2),eXYZ(einSOZ,3));
        colormap(gca,color_e); 
        alpha(s_alpha);     
        shading flat; 
        lightsout; 
        litebrain('sal',1)
        %litebrain('saarrrr',0)
        view(215,20)
        lighting phong
        axis equal
        axis([min(eXYZ(:,1))-w max(eXYZ(:,1))+w   min(eXYZ(:,2))-w max(eXYZ(:,2))+w   min(eXYZ(:,3))-w max(eXYZ(:,3))+w])
        
    end
    drawnow

        if initialframe==1;
            clear F; f=1;
            F(f)=getframe(gcf); 
            f=f+1;
        end

end

