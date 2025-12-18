function data_out = recursiveStrRep(data_in, targetStr, newStr)
    % Recursively walk through any nested struct or cell array and replace
    % all occurrences of a target string in any 'char' fields.

    % Initialize the output as the input.
    % This way, numeric/other types are passed through unchanged.
    data_out = data_in;

    if ischar(data_in)
        % --- Base Case: Input is a string ---
        % This is what we're looking for. Do the replacement.
        data_out = strrep(data_in, targetStr, newStr);

    elseif isstruct(data_in)
        % --- Recursive Case 1: Input is a struct ---
        % We must loop over all elements (if it's a struct array)
        % and then all fields within each element.
        
        for k = 1:numel(data_in) % Loop over all elements (e.g., in a 1x5 struct)
            fields = fieldnames(data_in(k));
            
            for i = 1:length(fields)
                fieldName = fields{i};
                
                % Get the value of the field
                fieldValue = data_in(k).(fieldName);
                
                % Recursively call this function on the field's value
                % and update the output struct with the result.
                data_out(k).(fieldName) = recursiveStrRep(fieldValue, targetStr, newStr);
            end
        end

    elseif iscell(data_in)
        % --- Recursive Case 2: Input is a cell array ---
        % We must loop over all elements in the cell
        % and apply this function to each one.
        
        % We use a simple loop to preserve the shape of the cell array
        for i = 1:numel(data_in)
            
            % Get the contents of the cell
            cellElement = data_in{i};
            
            % Recursively call this function on the cell's contents
            % and update the output cell with the result.
            data_out{i} = recursiveStrRep(cellElement, targetStr, newStr);
        end
        
    % --- Base Case 2: Input is numeric, logical, etc. ---
    % Do nothing. 'data_out' is already equal to 'data_in'.
    end
end
