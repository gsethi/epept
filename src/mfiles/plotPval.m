% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warranty Disclaimer and Copyright Notice
%
% Copyright (C) 2003-2010 Institute for Systems Biology, Seattle, Washington, USA.
%
% The Institute for Systems Biology and the authors make no representation about the suitability or accuracy of this software for any purpose, and makes no warranties, either express or implied, including merchantability and fitness for a particular purpose or that the use of this software will not infringe any third party patents, copyrights, trademarks, or other rights. The software is provided "as is". The Institute for Systems Biology and the authors disclaim any liability stemming from the use of this software. This software is provided to enhance knowledge and encourage progress in the scientific community.
%
% This is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.
%
% You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotPval(name,header,H,P,Pci);

fn = 'CourierNew';
fs = 13;


try

    %parameters
    C = length(P);
    lw = 5;
    d1 = .4;
    d2 = .25;
    map = colormap;close;
    h = figure; hold on;
    YTN = 10;


    if nargin==4;

        P2 = log10(P);
        miny = floor(min([-1 P2(find(P~=0))]));
        maxy = 0;
        if any(P==0);
            miny = miny-1;
            P2(find(P==0)) = miny;
        end
        Colors = round(interp1(linspace(maxy,miny,size(map,1)),1:size(map,1),P2));
        for c = 1:C;
            if isnan(P(c));
                ht = text(c,-.5,'NaN');
                set(ht,'FontName',fn,'FontSize',fs,'HorizontalAlignment','center','VerticalAlignment','middle','FontWeight','bold');
            else
                plot([c-d1 c+d1],[P2(c) P2(c)],'LineWidth',lw,'Color',map(Colors(c),:));
                plot([c-d1 c+d1],[P2(c) P2(c)],'LineWidth',lw/2,'Color',map(Colors(c),:));
            end
        end

        YTick = unique(round(linspace(miny,maxy,YTN)));
        for n = 1:length(YTick);
            if n==1&any(P==0);
                YTickL{n} = '0';
            else
                YTickL{n} = ['1e' num2str(YTick(n))];
            end
        end

        set(gca,'Xlim',[.5 C+.5],'Ylim',[miny-.5 maxy],'XTick',1:C,'YTick',YTick,'YTickLabel',YTickL);grid on
        if header==1;
            hText = xticklabel_rotate(1:C,45,H,'interpreter','none');
        end
        
        print(h,'-depsc2','-loose',name);close
        eval(['! /local/tknijnen/robot-cornea/sam2p-0.47/sam2p -l:gs=-r300 -j:quiet ' name ' ' name(1:end-4) '.png  >& /dev/null']);
    

    elseif nargin==5;
       
        P2 = log10(P);
        Pci2 = log10(Pci);
        miny = floor(min([-1 P2(find(P~=0)) Pci2(1,find(Pci(1,:)~=0))]));
        maxy = 0;
        if any(P==0)|any(Pci(1,:)==0);
            miny = miny-1;
            P2(find(P==0)) = miny;
            Pci2(1,find(Pci(1,:)==0)) = miny;
            Pci2(2,find(Pci(2,:)==0)) = miny;
        end
        Colors = round(interp1(linspace(maxy,miny,size(map,1)),1:size(map,1),P2));
        ColorsLB = round(interp1(linspace(maxy,miny,size(map,1)),1:size(map,1),Pci2(1,:)));
        ColorsUB = round(interp1(linspace(maxy,miny,size(map,1)),1:size(map,1),Pci2(2,:)));
        for c = 1:C;
            if isnan(P(c));
                ht = text(c,-.5,'NaN');
                set(ht,'FontName',fn,'FontSize',fs,'HorizontalAlignment','center','VerticalAlignment','middle');
            elseif any(isnan(Pci(:,c)))
                ht = text(c,-.5,'No ci');
                set(ht,'FontName',fn,'FontSize',fs,'HorizontalAlignment','center','VerticalAlignment','middle');
                plot([c-d1 c+d1],[P2(c) P2(c)],'LineWidth',lw,'Color',map(Colors(c),:));
            else
                patch([c-d2 c+d2 c+d2 c-d2],[Pci2(1,c) Pci2(1,c) Pci2(2,c) Pci2(2,c)],[ColorsLB(c) ColorsLB(c) ColorsUB(c) ColorsUB(c)])
                plot([c-d1 c+d1],[P2(c) P2(c)],'LineWidth',lw,'Color',map(Colors(c),:));
                plot([c-d1 c+d1],[P2(c) P2(c)],'LineWidth',lw/2,'Color',[0 0 0]);
            end
        end

       YTick = unique([miny miny:ceil((maxy-miny)/YTN):maxy maxy]);
        
        for n = 1:length(YTick);
            if n==1&any(Pci(1,:)==0);
                YTickL{n} = '0';
            else
                YTickL{n} = ['1e' num2str(YTick(n))];
            end
        end
        
        set(gca,'Xlim',[.5 C+.5],'Ylim',[miny-.5 maxy],'XTick',1:C,'YTick',YTick,'YTickLabel',YTickL);grid on
        if header==1;
            hText = xticklabel_rotate(1:C,45,H,'interpreter','none');
        end
        
        print(h,'-depsc2','-loose',name);close
        eval(['! /local/tknijnen/robot-cornea/sam2p-0.47/sam2p -l:gs=-r300 -j:quiet ' name ' ' name(1:end-4) '.png  >& /dev/null']);

    end


catch

    L = lasterror;
    display(L.message);
    h = figure;
    ht = text(0,0,'Plot Failed');
    set(ht,'FontName',fn,'FontSize',fs,'HorizontalAlignment','center','VerticalAlignment','middle')
    set(gca,'Xlim',[-1 1],'Ylim',[-1 1],'XTick',[],'YTick',[],'Color',[1 1 1]);
    print(h,'-dpng',name)
    close

end



