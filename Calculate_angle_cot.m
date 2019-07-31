% data=importdata('new_Bunny_head (另一个复件).obj');
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
% length=zeros(size(face,1),3);
% for i=1:3
%     format long
%     (vertex(face(:,mod(i,3)+1),:)-vertex(face(:,mod(i+1,3)+1),:)).^2;
%     length(:,i)=sum((vertex(face(:,mod(i,3)+1),:)-vertex(face(:,mod(i+1,3)+1),:)).^2,2);
% end
% format long
% length
% angle=zeros(size(face,1),3);
% for i=1:3
%     angle(:,i)=acos((length(:,mod(i,3)+1)+length(:,mod(i+1,3)+1)-length(:,i))./sqrt(length(:,mod(i+1,3)+1).*length(:,mod(i,3)+1))/2) ;  
% end
% angle;
% 
% length(size(length,1)-13,:)
% face(size(length,1)-13,:)
% vertex(266,:)-vertex(253,:)
% vertex(266,:)-vertex(248,:)
% (vertex(253,:)-vertex(248,:))
% vertex(253,:)
% vertex(248,:)


% function angle=Calculate_angle(vertex,face)
% length=zeros(size(face,1),3);
% for i=1:3
%     length(:,i)=sum((vertex(face(:,mod(i,3)+1),:)-vertex(face(:,mod(i+1,3)+1),:)).^2,2);
% end
% angle=zeros(size(face,1),3);
% for i=1:3
%     angle(:,i)=acos((length(:,mod(i,3)+1)+length(:,mod(i+1,3)+1)-length(:,i))./sqrt(length(:,mod(i+1,3)+1).*length(:,mod(i,3)+1))/2);    
% end
% end

function angle_cot=Calculate_angle_cot(vertex,face)
length=zeros(size(face,1),3);
for i=1:3
    for j=1:size(face,1)
        length(j,i)=sum((vertex(face(j,mod(i,3)+1),:)-vertex(face(j,mod(i+1,3)+1),:)).^2,2);
    end    
end
angle_cos=zeros(size(face,1),3);
for i=1:3
    angle_cos(:,i)=(length(:,mod(i,3)+1)+length(:,mod(i+1,3)+1)-length(:,i))./sqrt(length(:,mod(i+1,3)+1).*length(:,mod(i,3)+1))/2.0;    
end
angle_sin=sqrt(1-angle_cos.^2);
angle_cot=angle_cos./angle_sin;
% face(20,:)
% vertex(face(20,1),:)
% vertex(face(20,2),:)
% vertex(face(20,3),:)
% sum((vertex(face(20,1),:)-vertex(face(20,2),:)).^2)
% sum((vertex(face(20,1),:)-vertex(face(20,3),:)).^2)
% sum((vertex(face(20,2),:)-vertex(face(20,3),:)).^2)
% format long e
% length(20,:)
% angle(20,:)
% sum(angle(20,:))
% for i=1:3
%     (length(20,mod(i,3)+1)+length(20,mod(i+1,3)+1)-length(20,i))./sqrt(length(20,mod(i+1,3)+1))/sqrt(length(20,mod(i,3)+1))/2
% end
end