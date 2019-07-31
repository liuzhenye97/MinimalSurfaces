% data=importdata('Bunny_head.obj');
% sprintf('点的个数为%d,面的个数为%d',data.data(1,1),data.data(2,1))
% vertex=zeros(data.data(1,1),3);
% face=zeros(data.data(2,1),3);
% vertex_no=1;
% face_no=1;
% for i=1:(size(data.textdata,1))  
%     if char(data.textdata(i,1))=='v'
%         vertex(vertex_no,:)=str2num(char(data.textdata(i,2:4)));
%         vertex_no=vertex_no+1;
%     elseif char(data.textdata(i,1))=='f'
%         face(face_no,:)=str2num(char(data.textdata(i,2:4)));
%         face_no=face_no+1;
%     end
% end
% if vertex_no~=data.data(1,1)+1 || face_no~=data.data(2,1)+1
%     disp('error')
% end 
% 
% length=zeros(size(face,1),3);
% for i=1:3
%     length(:,i)=sum((vertex(face(:,mod(i,3)+1),:)-vertex(face(:,mod(i+1,3)+1),:)).^2,2);
% end
% angle=zeros(size(face,1),3);
% for i=1:3
%     angle(:,i)=acos((length(:,mod(i,3)+1)+length(:,mod(i+1,3)+1)-length(:,i))./sqrt(length(:,mod(i+1,3)+1).*length(:,mod(i,3)+1))/2);    
% end
% area=sqrt(length(:,2).*length(:,3)).*sin(angle(:,1))/2
% area_sum=sum(area())

% function area_sum=Calculate_area(vertex,face)
% length=zeros(size(face,1),3);
% for i=1:3
%     length(:,i)=sum((vertex(face(:,mod(i,3)+1),:)-vertex(face(:,mod(i+1,3)+1),:)).^2,2);
% end
% angle=zeros(size(face,1),3);
% for i=1:3
%     angle(:,i)=acos((length(:,mod(i,3)+1)+length(:,mod(i+1,3)+1)-length(:,i))./sqrt(length(:,mod(i+1,3)+1).*length(:,mod(i,3)+1))/2);    
% end
% area=sqrt(length(:,2).*length(:,3)).*sin(angle(:,1))/2;
% area_sum=sum(area());
% end


function area_sum=Calculate_area(vertex,face)
length=zeros(size(face,1),3);
for i=1:3
    length(:,i)=sqrt(sum((vertex(face(:,mod(i,3)+1),:)-vertex(face(:,mod(i+1,3)+1),:)).^2,2));
end
p=sum(length,2)/2;
area=sqrt(p.*(p-length(:,1)).*(p-length(:,2)).*(p-length(:,3)));
area_sum=sum(abs(area()));
end
