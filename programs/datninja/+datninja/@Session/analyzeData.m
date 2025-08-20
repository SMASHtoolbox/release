function analyzeData(object)

M=size(object.DataTable,1);
if M < 1
    object.DataTable=nan(0,4);
    return
end

ref=object.DataTable(:,1:2);
data=calculateXY(object,ref);
object.DataTable(:,3:4)=data;

end