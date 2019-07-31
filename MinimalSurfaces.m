
%读取obj。兼容性不好，如果读取的不是类似‘Bunny_head.obj’结构的obj文件可能读不出来。
data=importdata('Bunny_head.obj');
sprintf('点的个数为%d,面的个数为%d',data.data(1,1),data.data(2,1))
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
%找到全部边并存储
edge=zeros(3*size(face,1),2);
for i=1:size(face,1)
    edge(3*(i-1)+1,1)=face(i,1);
    edge(3*(i-1)+1,2)=face(i,2);
    edge(3*(i-1)+2,1)=face(i,1);
    edge(3*(i-1)+2,2)=face(i,3);
    edge(3*(i-1)+3,1)=face(i,2);
    edge(3*(i-1)+3,2)=face(i,3);
end
%将序号小的点放在前面
for i=1:3*size(face,1)
    if edge(i,1)>edge(i,2)
        temp=edge(i,1);
        edge(i,1)=edge(i,2);
        edge(i,2)=temp;
    end
end
%寻找边界。
%1.将边按照第一个点的序号排序
%2.将第一个序号相同的边按照第二个序号排序
%3.通过前后的点是否相同判断是不是边界，从而找到边界点

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


%利用稀疏矩阵存储点是否相邻的关系
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
number_of_adjacency=full(sum(is_adjacent,2)); %每个点的相邻点个数的二倍

number_of_inside=size(vertex,1)-sum(point_label(:)); %内部点个数

%计算矩阵A,A存储各点权值
A=sparse(number_of_inside,number_of_inside);
for i=1:number_of_inside
    A(i,i)=1;
end
x=1; %x及下面的y表示除掉边界点后的序号
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


%矩阵b
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

%变换后的内部点的位置
new_position=A\b;

t2=clock;

%将结果输入new_Bunny_head.obj
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

sprintf('所用时间为%.6f秒,面积为%.6f',etime(t2,t1),area)
