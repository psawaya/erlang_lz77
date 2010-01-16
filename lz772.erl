-module(lz772).

-author('me@paulsawaya.com').
-compile(export_all).

decompress(String) ->
    Dico = dict:new(),

    decompress(String,Dico,256,[],[],[]).

decompress([],_,_,_,_,Result) ->
    Result;

decompress([Code|String],Dico,NbChar,Buffer,Chain,Result) ->
    Current = is_ascii_or_in_dict(Dico,Code),
    case Buffer of
        [] ->
            NewBuffer = listify(Current),
            NewResult = Result ++ listify(Current),
            decompress(String,Dico,NbChar,NewBuffer,Chain,NewResult);
        _ ->
            if 
                Code =< 255 ->
                    NewResult = Result ++ listify(Current),
                    NewChain = Buffer ++ listify(Current),

                    NewDico = dict:append(NbChar,NewChain,Dico),
                    NewBuffer = listify(Current),
                    decompress(String,NewDico,NbChar+1,NewBuffer,NewChain,NewResult);
                
                true ->

                    if 
                        Current == [] ->
                            NewChain = Buffer ++ listify(nth_or_empty_list(1,Buffer));
                        
                        true ->
                            NewChain = listify(Current)
                    end,
                    
                    NewResult = Result ++ listify(NewChain),

                    NewDico = dict:append(NbChar,Buffer ++ listify(nth_or_empty_list(1,NewChain)), Dico),
                    NewBuffer = NewChain,
                    
                    decompress(String,NewDico,NbChar+1,NewBuffer,NewChain,NewResult)
                end
            end.
    

compress(String) ->
    Dico = dict:new(),

    compress(String ++ [0],Dico,[],256,[]).
    
compress([],_,_,_,Result) ->
    Result;

compress([Current|String],Dico,Buffer,NbChar,Result) ->

    case is_ascii_or_in_dict(Dico,Buffer ++ [Current]) of
        [] ->
            AddToRes = is_ascii_or_in_dict(Dico,Buffer),
            
            if 
                AddToRes == [] -> 
                    throw(notFoundInBuffer);
                true ->

                    NewResult = Result ++ listify(AddToRes),
                    NewDico = dict:append(Buffer ++ [Current],NbChar,Dico),
                    NewNbChar = NbChar + 1,
                    NewBuffer = [Current],
                    compress(String,NewDico,NewBuffer,NewNbChar,NewResult)
            
            end;
        
        _ ->
            compress(String,Dico,Buffer ++ [Current],NbChar,Result)
    end.
          
nth_or_empty_list(N,List) ->
    if
        length(List) >= N ->
            lists:nth(N,List);
            
        true ->
            []
    end.

listify(Thing) when is_list(Thing) ->
    Thing;

listify(Thing) ->
    [Thing].
    
is_ascii_or_in_dict(Dico,[Lookup]) ->
    is_ascii_or_in_dict(Dico,Lookup);

is_ascii_or_in_dict(Dico,Lookup) ->
     case dict:find(Lookup,Dico) of
        error ->
            if
                ((Lookup >= 0) and (Lookup =< 256)) ->
                    %If lookup is an ASCII char, just return it without storing them in the Dico
                    Lookup;
                true ->
                    []
            end;
        
        {ok,[Value]} ->
                Value
    end.
        