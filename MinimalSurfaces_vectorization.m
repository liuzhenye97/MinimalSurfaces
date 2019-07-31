
%��ȡobj�������Բ��ã������ȡ�Ĳ������ơ�Bunny_head.obj���ṹ��obj�ļ����ܶ���������
data=importdata('Bunny_head.obj');
sprintf('��ĸ���Ϊ%d,��ĸ���Ϊ%d',data.data(1,1),data.data(2,1))
vertex=zeros(data.data(1,1),3);
face=zeros(data.data(2,1),3);
vertex_no=1;
face_no=1;
for i=1:(size(data.textdata,1))  
    if char(data.textdata(i,1))=='v'
        vertex(vertex_no,:)=str2num(char(data.textdata(i,2:4)));
        vertex_no=vertex_no+1;
    elseif char(data.textdata(i,1))=='f'
        face(face_no,:)=str2num(char(data.textdata(i,2:4)));
        face_no=face_no+1;
    end
end
if vertex_no~=data.data(1,1)+1 || face_no~=data.data(2,1)+1
    disp('error')
end   

t1=clock;
%�ҵ�ȫ���߲��洢
edge=zeros(3*size(face,1),2);
for i=1:size(face,1)
   edge(3*(i-1)+1,1)=face(i,1);
   edge(3*(i-1)+1,2)=face(i,2);
   edge(3*(i-1)+2,1)=face(i,1);
   edge(3*(i-1)+2,2)=face(i,3);
   edge(3*(i-1)+3,1)=face(i,2);
   edge(3*(i-1)+3,2)=face(i,3);
end



i=1:3*size(face,1);
I=edge(i,1)>edge(i,2);
temp1=edge(i,1);
temp2=edge(i,2);
edge(i,1)=I.*temp2+(1-I).*temp1;
edge(i,2)=I.*temp1+(1-I).*temp2;


[~,index]=sort(edge(:,1));
edge=edge(index,:);


edge_value=size(vertex,1)*edge(:,1)+edge(:,2);
[aaa,index]=sort(edge_value);
edge=edge(index,:);



point_label=zeros(size(vertex,1),1);
point_value=edge(:,1)*size(vertex,1)+edge(:,2);
point_value=point_value';
difference  = diff([point_value,max(point_value)+1]);
count = diff(find([1,difference]));
y=find(difference);
z=y(count==1);
point_label(edge(z,1),1)=1;
point_label(edge(z,2),1)=1;

%����ϡ�����洢���Ƿ����ڵĹ�ϵ
edge_a=zeros(6*size(face,1),1);
edge_b=zeros(6*size(face,1),1);
for i=1:size(face,1)
    edge_a(6*(i-1)+1,1)=face(i,1);
    edge_a(6*(i-1)+2,1)=face(i,1);
    edge_a(6*(i-1)+3,1)=face(i,2);
    edge_a(6*(i-1)+4,1)=face(i,2);
    edge_a(6*(i-1)+5,1)=face(i,3);
    edge_a(6*(i-1)+6,1)=face(i,3);
    edge_b(6*(i-1)+1,1)=face(i,2);
    edge_b(6*(i-1)+2,1)=face(i,3);
    edge_b(6*(i-1)+3,1)=face(i,1);
    edge_b(6*(i-1)+4,1)=face(i,3);
    edge_b(6*(i-1)+5,1)=face(i,1);
    edge_b(6*(i-1)+6,1)=face(i,2);
end


is_adjacent=sparse(edge_a,edge_b,ones(6*size(face,1),1));
number_of_adjacency=full(sum(is_adjacent,2)); %ÿ��������ڵ�����Ķ���
number_of_inside=size(vertex,1)-sum(point_label(:)); %�ڲ������


%�������A,A�洢����Ȩֵ
A=sparse(number_of_inside,number_of_inside);
for i=1:number_of_inside
    A(i,i)=1;
end
x=1;%x�������y��ʾ�����߽�������
for i=1:size(vertex,1)   
    if point_label(i,1)==0 
        y=1;
            vertex_number= size(vertex,1);
            j=1:vertex_number;
            index= (i~=j) & is_adjacent(i,:)>0 & (point_label(:,1)==0)';              
            A_x=-2.0/number_of_adjacency(i,1)*index;                    
            coor1=find(point_label(:,1)==0);             
            A_x=A_x(coor1);            
            coor2=find(A_x);
            A(x,coor2)=A_x(coor2);
        x=x+1;
    end
end



%����b
b=zeros(number_of_inside,3);
x=1;


for i=1:size(vertex,1)   
    if point_label(i,1)==0
            j=1:size(vertex,1);
            index=i~=j & (point_label(j,1)==1)' & is_adjacent(i,j)>0;          
            size(index);
            b(x,:)=b(x,:)+2*index*vertex(:,:)/number_of_adjacency(i,1);        
        x=x+1;
    end
end


%�任����ڲ����λ��
new_position=A\b;
t2=clock;


%���������new_Bunny_head.obj
fid=fopen(['new_Bunny_head2.obj'],'w');
x=1;
for i=1:size(vertex,1)
    if point_label(i,1)==1
        fprintf(fid,'v %.10f %.10f %.10f\r\n',vertex(i,1),vertex(i,2),vertex(i,3)); 
    else
        fprintf(fid,'v %.10f %.10f %.10f\r\n',new_position(x,1),new_position(x,2),new_position(x,3));
        vertex(i,:)=new_position(x,:);
        x=x+1;       
    end
end
for i=1:size(face,1)
    fprintf(fid,'f %d %d %d\r\n',face(i,1),face(i,2),face(i,3));   
    
end
fclose(fid);



area=Calculate_area(vertex,face);

sprintf('����ʱ��Ϊ%.6f��,���Ϊ%.6f',etime(t2,t1),area)