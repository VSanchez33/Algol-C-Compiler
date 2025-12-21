int x[5];

int func(int i, int j) 
begin 
    while i >= 0 do
    begin 
        write "Array val: ";
        write x[i]; 
        write "\n";
        i = i - 1; 
    end

    if x[1] == 5 then 
    begin
        return i or j; 
    end

    else
    begin 
        return i and j;
    end
    endif
end

void main(void) 
begin
    int i; 
    i = 0; 

    while i < 5 do 
    begin
        write "Enter array val: ";
        read x[i]; 
        i = i + 1; 
    end

    write func(i-1, 1000); 
end