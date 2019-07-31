
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
%�����С�ĵ����ǰ��
for i=1:3*size(face,1)
    if edge(i,1)>edge(i,2)
        temp=edge(i,1);
        edge(i,1)=edge(i,2);
        edge(i,2)=temp;
    end
end
%Ѱ�ұ߽硣
%1.���߰��յ�һ������������
%2.����һ�������ͬ�ı߰��յڶ����������
%3.ͨ��ǰ��ĵ��Ƿ���ͬ�ж��ǲ��Ǳ߽磬�Ӷ��ҵ��߽��

for i=1:3*size(face,1)
    for j=i+1:3*size(face,1)
        if edge(i,1)>edge(j,1)
            temp=edge(i,:);
            edge(i,:)=edge(j,:);
            edge(j,:)=temp;
        end
    end
end

for i=1:3*size(face,1)
    for j=i+1:3*size(face,1)
        if edge(i,1)==edge(j,1) && edge(i,2)>edge(j,2)
            temp=edge(i,:);
            edge(i,:)=edge(j,:);
            edge(j,:)=temp;
        end
    end
end


point_label=zeros(size(vertex,1),1);
for i=1:3*size(face,1)
    if i==1
        if edge(i,1)~=edge(i+1,1) || edge(i,2)~=edge(i+1,2)
            point_label(edge(i,1),1)=1;
            point_label(edge(i,2),1)=1;
        end
    elseif i==3*size(face,1)
        if edge(i,1)~=edge(i-1,1) || edge(i,2)~=edge(i-1,2)
            point_label(edge(i,1),1)=1;
            point_label(edge(i,2),1)=1;
        end        
    else
        if (edge(i,1)~=edge(i+1,1) || edge(i,2)~=edge(i+1,2)) && (edge(i,1)~=edge(i-1,1) || edge(i,2)~=edge(i-1,2))

            point_label(edge(i,1),1)=1;
            point_label(edge(i,2),1)=1;
        end
    end       
end


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
x=1; %x�������y��ʾ�����߽�������
for i=1:size(vertex,1)   
    if point_label(i,1)==0 
        y=1;
        for j=1:size(vertex,1)
            if i~=j
                if is_adjacent(i,j)>0 && point_label(j,1)==0
                    A(x,y)=-2.0/number_of_adjacency(i,1);                    
                end               
            end
            if point_label(j,1)==0
                    y=y+1;
            end
        end
        x=x+1;
    end
end


%����b
b=zeros(number_of_inside,3);
x=1;
for i=1:size(vertex,1)   
    if point_label(i,1)==0
        for j=1:size(vertex,1)
            if i~=j && point_label(j,1)==1 && is_adjacent(i,j)>0
                b(x,:)=b(x,:)+2*vertex(j,:)/number_of_adjacency(i,1);
            end
        end
        x=x+1;
    end
end

%�任����ڲ����λ��
new_position=A\b;

t2=clock;

%���������new_Bunny_head.obj
fid=fopen(['new_Bunny_head.obj'],'w');
x=1;
for i=1:size(vertex,1)
    if point_label(i,1)==1
        fprintf(fid,'v %.4f %.4f %.4f\r\n',vertex(i,1),vertex(i,2),vertex(i,3)); 
    else
        fprintf(fid,'v %.4f %.4f %.4f\r\n',new_position(x,1),new_position(x,2),new_position(x,3));
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
