function dynamicSelect()

dlg=SMASH.MUI.Dialog;
dlg.Name='Dynamic bound';
minwidth=10;

list=cell(1,1000);
L=0;
for m=1:numel(list)
    list{m}=sprintf('%d',m);
    L=max(L,numel(list{m}));
end
h=addblock(dlg,'popup',' ',list,L+2);
set(h(1),'String','Current point:');
position=get(h(1),'Position');
extent=get(h(1),'Extent');
position(3)=extent(3);
set(h(1),'Position',position); % bit persnickety!

h=addblock(dlg,'buttons','Remove point');

h=addblock(dlg,'edit','Time:',minwidth);

h=addblock(dlg,'edit','Center:',minwidth);

%h=addblock(dlg,'edit','Width:',minwidth);

h=addblock(dlg,'edit_button',{'Width','common'},minwidth);
%h=addblock(dlg,'buttons',{'Common width'});

h=addblock(dlg,'buttons',{'OK','cancel'});

end