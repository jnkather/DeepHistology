function dispUniqueValues(inValues,numMax)

dispU = cellstr(unique(inValues));
   if numel(dispU)>numMax
	disp(dispU(1:numMax)); 
	disp('... and others!...');
   else
	disp(dispU);
   end
   
end    