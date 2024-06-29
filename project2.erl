-module(project2).
-export([main/3,lineGossip/5,twoDGossip/14,fullGossip/3,linePushSum/6,twoDPushSum/15,fullPushSum/4,nodeList/1,getNodeList/4,createNetwork/5,createNetwork/6,updateNetwork/2,updateNetwork/4]).

%Gossip Algorithms

lineGossip(NodeNumber, Previous, Next, Count, NodeList) ->
    receive
        {updateList, UpdatedNodeList} ->
            lineGossip(NodeNumber, Previous, Next, Count, UpdatedNodeList);
        {updatenext, UpdatedNext} ->
            lineGossip(NodeNumber, Previous, UpdatedNext, Count, NodeList);
        {updateprevious, UpdatedPrevious} ->
            lineGossip(NodeNumber, UpdatedPrevious, Next, Count, NodeList);
        get_gossip ->
            if
                Count >= 9 ->
                    if
                        Next =/= x ->
                            NextNodeName = "node_"++integer_to_list(Next),
                            {ok, NextNode} = dict:find(NextNodeName, NodeList),
                            NextNode ! {updateprevious, Previous};
                        true ->
                            ok
                    end,
                    if
                        Previous =/= x ->
                            PreviousNodeName = "node_"++integer_to_list(Previous),
                            {ok, PreviousNode} = dict:find(PreviousNodeName, NodeList),
                            PreviousNode ! {updatenext, Next};
                        true ->
                            ok
                    end,
                    nodeList ! {deletefromnodelist, NodeNumber},
                    io:format("Node: ~w heard rumour 10 times. *Node Terminated* ~n",[NodeNumber]),
                    exit(normal);
                true ->
                    io:format("Node: ~w heard rumour ~w times.~n",[NodeNumber, Count + 1]),
                    lineGossip(NodeNumber, Previous, Next, Count + 1, NodeList)
            end
    after 100 ->
        if 
            Count > 0 ->
                ok;
            true ->
                lineGossip(NodeNumber, Previous, Next, Count, NodeList)
        end,
        nodeList ! {getnodelist, self()},
        receive
            {updatenodenumberlist, UpdatedNodeNumberList} ->
                AllActiveNodeList = UpdatedNodeNumberList
        after 100 ->
            io:format("Main Node List Not Responding~n", []),
            AllActiveNodeList = [],
            exit(timeout)
        end,
        PreviousActive = lists:member(Previous, AllActiveNodeList),
        NextActive = lists:member(Next, AllActiveNodeList),
        if
            (Previous == x) or not PreviousActive ->
                UpdatedPrevious = x,
                PreviousNodeList = [];
            true ->
                UpdatedPrevious = Previous,
                PreviousNodeList = [Previous]
        end,
        if
            (Next == x) or not NextActive ->
                UpdatedNext = x,
                NextNodeList = [];
            true ->
                UpdatedNext = Next,
                NextNodeList = [Next]
        end,
        NeighborNodeList = lists:append(PreviousNodeList, NextNodeList),        
        if
            length(NeighborNodeList) == 0 ->
                nodeList ! {deletefromnodelist, NodeNumber},
                io:format("Node : ~w heard the rumour ~w times. *Terminating since no neighbours are active* ~n",[ NodeNumber,Count]),
                exit(normal);
            true ->
                SendNodeNumber = lists:nth(rand:uniform(length(NeighborNodeList)), NeighborNodeList),
                SendNodeName = "node_"++integer_to_list(SendNodeNumber),
                {ok, SendNode} = dict:find(SendNodeName, NodeList),
                SendNode ! get_gossip,
                lineGossip(NodeNumber, Previous, Next, Count, NodeList)
        end
    end.


twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type) ->
    receive
        {updateList, UpdatedNodeList} ->
            twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, UpdatedNodeList, Type);
        {updatetop, UpdatedTop} ->
            twoDGossip(I, J, N, UpdatedTop, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type);
        {updatebottom, UpdatedBottom} ->
            twoDGossip(I, J, N, Top, UpdatedBottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type);
        {updateleft, UpdatedLeft} ->
            twoDGossip(I, J, N, Top, Bottom, UpdatedLeft, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type);
        {updateright, UpdatedRight} ->
            twoDGossip(I, J, N, Top, Bottom, Left, UpdatedRight, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type);
        {updatetopleft, UpdatedTopLeft} ->
            twoDGossip(I, J, N, Top, Bottom, Left, Right, UpdatedTopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type);
        {updatetopright, UpdatedTopRight} ->
            twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, UpdatedTopRight, BottomLeft, BottomRight, Count, NodeList, Type);
        {updatebottomleft, UpdatedBottomLeft} ->
            twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, UpdatedBottomLeft, BottomRight, Count, NodeList, Type);
        {updatebottomright, UpdatedBottomRight} ->
            twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, UpdatedBottomRight, Count, NodeList, Type);
        get_gossip ->
            if
                Count >= 9 ->
                    if
                        Top =/= [x,x] ->
                            TopNodeName = "node_"++integer_to_list(lists:nth(1,Top))++"_"++integer_to_list(lists:nth(2,Top)),
                            {ok, TopNode} = dict:find(TopNodeName, NodeList),
                            TopNode ! {updatebottom, Bottom};
                        true ->
                            ok
                    end,
                    if
                        Bottom =/= [x,x] ->
                            BottomNodeName = "node_"++integer_to_list(lists:nth(1,Bottom))++"_"++integer_to_list(lists:nth(2,Bottom)),
                            {ok, BottomNode} = dict:find(BottomNodeName, NodeList),
                            BottomNode ! {updatetop, Top};
                        true ->
                            ok
                    end,
                    if
                        Left =/= [x,x] ->
                            LeftNodeName = "node_"++integer_to_list(lists:nth(1,Left))++"_"++integer_to_list(lists:nth(2,Left)),
                            {ok, LeftNode} = dict:find(LeftNodeName, NodeList),
                            LeftNode ! {updateright, Right};
                        true ->
                            ok
                    end,
                    if
                        Right =/= [x,x] ->
                            RightNodeName = "node_"++integer_to_list(lists:nth(1,Right))++"_"++integer_to_list(lists:nth(2,Right)),
                            {ok, RightNode} = dict:find(RightNodeName, NodeList),
                            RightNode ! {updateleft, Left};
                        true ->
                            ok
                    end,
                    if
                        TopLeft =/= [x,x] ->
                            TopLeftNodeName = "node_"++integer_to_list(lists:nth(1,TopLeft))++"_"++integer_to_list(lists:nth(2,TopLeft)),
                            {ok, TopLeftNode} = dict:find(TopLeftNodeName, NodeList),
                            TopLeftNode ! {updatebottomright, BottomRight};
                        true ->
                            ok
                    end,
                    if
                        TopRight =/= [x,x] ->
                            TopRightNodeName = "node_"++integer_to_list(lists:nth(1,TopRight))++"_"++integer_to_list(lists:nth(2,TopRight)),
                            {ok, TopRightNode} = dict:find(TopRightNodeName, NodeList),
                            TopRightNode ! {updatebottomleft, BottomLeft};
                        true ->
                            ok
                    end,
                    if
                        BottomLeft =/= [x,x] ->
                            BottomLeftNodeName = "node_"++integer_to_list(lists:nth(1,BottomLeft))++"_"++integer_to_list(lists:nth(2,BottomLeft)),
                            {ok, BottomLeftNode} = dict:find(BottomLeftNodeName, NodeList),
                            BottomLeftNode ! {updatetopright, TopRight};
                        true ->
                            ok
                    end,
                    if
                        BottomRight =/= [x,x] ->
                            BottomRightNodeName = "node_"++integer_to_list(lists:nth(1,BottomRight))++"_"++integer_to_list(lists:nth(2,BottomRight)),
                            {ok, BottomRightNode} = dict:find(BottomRightNodeName, NodeList),
                            BottomRightNode ! {updatetopleft, TopLeft};
                        true ->
                            ok
                    end,
                    nodeList ! {deletefromnodelist, [I,J]},
                    io:format("Node: (~w,~w) heard rumour 10 times. *Node Terminated*~n",[I, J]),
                    exit(normal);
                true ->
                    io:format("Node: (~w,~w) heard rumour ~w times.~n",[I, J, Count + 1]),
                    twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count + 1, NodeList, Type)
            end
    after 100 ->
        if 
            Count > 0 ->
                ok;
            true ->
                twoDGossip(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type)
        end,
        nodeList ! {getnodelist, self()},
        receive
            {updatenodenumberlist, UpdatedNodeNumberList} ->
                AllActiveNodeList = UpdatedNodeNumberList
        after 100 ->
            io:format("Main Node List Not Responding~n", []),
            AllActiveNodeList = [],
            exit(timeout)
        end,
        TopActive = lists:member(Top, AllActiveNodeList),
        BottomActive = lists:member(Bottom, AllActiveNodeList),
        LeftActive = lists:member(Left, AllActiveNodeList),
        RightActive = lists:member(Right, AllActiveNodeList),
        TopLeftActive = lists:member(TopLeft, AllActiveNodeList),
        TopRightActive = lists:member(TopRight, AllActiveNodeList),
        BottomLeftActive = lists:member(BottomLeft, AllActiveNodeList),
        BottomRightActive = lists:member(BottomRight, AllActiveNodeList),
        if
            (Top == [x,x]) or not TopActive ->
                UpdatedTop = [x,x],
                TopNodeList = [];
            true ->
                UpdatedTop = Top,
                TopNodeList = [Top]
        end,
        if
            (Bottom == [x,x]) or not BottomActive ->
                UpdatedBottom = [x,x],
                BottomNodeList = [];
            true ->
                UpdatedBottom = Bottom,
                BottomNodeList = [Bottom]
        end,
        if
            (Left == [x,x]) or not LeftActive ->
                UpdatedLeft = [x,x],
                LeftNodeList = [];
            true ->
                UpdatedLeft = Left,
                LeftNodeList = [Left]
        end,
        if
            (Right == [x,x]) or not RightActive ->
                UpdatedRight = [x,x],
                RightNodeList = [];
            true ->
                UpdatedRight = Right,
                RightNodeList = [Right]
        end,
        if
            (TopLeft == [x,x]) or not TopLeftActive ->
                UpdatedTopLeft = [x,x],
                TopLeftNodeList = [];
            true ->
                UpdatedTopLeft = TopLeft,
                TopLeftNodeList = [TopLeft]
        end,
        if
            (TopRight == [x,x]) or not TopRightActive ->
                UpdatedTopRight = [x,x],
                TopRightNodeList = [];
            true ->
                UpdatedTopRight = TopRight,
                TopRightNodeList = [TopRight]
        end,
        if
            (BottomLeft == [x,x]) or not BottomLeftActive ->
                UpdatedBottomLeft = [x,x],
                BottomLeftNodeList = [];
            true ->
                UpdatedBottomLeft = BottomLeft,
                BottomLeftNodeList = [BottomLeft]
        end,
        if
            (BottomRight == [x,x]) or not BottomRightActive ->
                UpdatedBottomRight = [x,x],
                BottomRightNodeList = [];
            true ->
                UpdatedBottomRight = BottomRight,
                BottomRightNodeList = [BottomRight]
        end,
        if
            Type == imperfect ->
                ActiveNodeList = lists:delete([I,J], AllActiveNodeList),
                RandomNode = lists:nth(rand:uniform(length(ActiveNodeList)), ActiveNodeList),
                RandomNodeList = [RandomNode];
            Type == grid ->
                RandomNodeList = []
        end,
        NeighborNodeList = lists:append([TopNodeList, BottomNodeList, LeftNodeList, RightNodeList, TopLeftNodeList, TopRightNodeList, BottomLeftNodeList, BottomRightNodeList, RandomNodeList]),
        if
            length(NeighborNodeList) ==0 ->
                nodeList ! {deletefromnodelist, [I,J]},
                io:format("Node : (~w,~w) heard the rumour ~w times. *Terminating since no neighbours are active*~n",[I, J, Count]),
                exit(normal);
            true ->
                SendNodeNumber = lists:nth(rand:uniform(length(NeighborNodeList)), NeighborNodeList),
                SendNodeName = "node_"++integer_to_list(lists:nth(1,SendNodeNumber))++"_"++integer_to_list(lists:nth(2,SendNodeNumber)),
                %io:format("TEST~s~p~n",[SendNodeName, NodeList]),
                {ok, SendNode} = dict:find(SendNodeName, NodeList),
                SendNode ! get_gossip,
                twoDGossip(I, J, N, UpdatedTop, UpdatedBottom, UpdatedLeft, UpdatedRight, UpdatedTopLeft, UpdatedTopRight, UpdatedBottomLeft, UpdatedBottomRight, Count, NodeList, Type)
        end
    end.

fullGossip(NodeNumber, Count, NodeList) ->
    receive
        {updateList, UpdatedNodeList} ->
            fullGossip(NodeNumber, Count, UpdatedNodeList);
        get_gossip ->
            if
                Count >= 9 ->
                    nodeList ! {deletefromnodelist, NodeNumber}, 
                    io:format("Node: ~w heard rumour 10 times. *Node Terminated* ~n",[NodeNumber]),
                    exit(normal);
                true ->
                    io:format("Node: ~w heard rumour ~w times. *Node Terminated* ~n",[NodeNumber, Count + 1]),
                    fullGossip(NodeNumber, Count + 1, NodeList)
            end
    after 100 ->
        if 
            Count > 0 ->
                ok;
            true ->
                fullGossip(NodeNumber, Count, NodeList)
        end,
        nodeList ! {getnodelist, self()},
        receive
            {updatenodenumberlist, UpdatedNodeNumberList} ->
                NeighborNodeList = lists:delete(NodeNumber, UpdatedNodeNumberList)
        after 100 ->
            io:format("Main Node List Not Responding~n", []),
            NeighborNodeList = [],
            exit(timeout)
        end,
        if
            length(NeighborNodeList) == 0 ->
                nodeList ! {deletefromnodelist, NodeNumber},
                io:format("Node : ~w heard the rumour ~w times. *Terminating since no neighbours are active* ~n",[NodeNumber, Count ]),
                exit(normal);
            true ->
                SendNodeNumber = lists:nth(rand:uniform(length(NeighborNodeList)), NeighborNodeList),
                SendNodeName = "node_"++integer_to_list(SendNodeNumber),
                {ok, SendNode} = dict:find(SendNodeName, NodeList),
                SendNode ! get_gossip,
                fullGossip(NodeNumber, Count, NodeList)
        end
    end.


%Push-Sum Algorithms

linePushSum(NodeNumber, Previous, Next, Count, NodeList, PushSumList) ->
    receive
        {updateList, UpdatedNodeList} ->
            linePushSum(NodeNumber, Previous, Next, Count, UpdatedNodeList, PushSumList);
        {updatenext, UpdatedNext} ->
            linePushSum(NodeNumber, Previous, UpdatedNext, Count, NodeList, PushSumList);
        {updateprevious, UpdatedPrevious} ->
            linePushSum(NodeNumber, UpdatedPrevious, Next, Count, NodeList, PushSumList);
        {get_gossip, PushSumValue} ->
            LastPushSumValue = lists:last(PushSumList),
            NewS = (lists:nth(1,LastPushSumValue)+lists:nth(1,PushSumValue)),
            NewW = (lists:nth(2,LastPushSumValue)+lists:nth(2,PushSumValue)),
            UpdatedPushSumValue = [NewS,NewW],
            UpdatedPushSumList = lists:append(PushSumList, [UpdatedPushSumValue]),
            io:format("Node : ~w heard the rumour ~w times. ~n",[NodeNumber, Count + 1]),
            if
                length(UpdatedPushSumList) > 4 ->
                    FinalPushSumList = lists:delete(lists:nth(1,UpdatedPushSumList),UpdatedPushSumList),
                    [S1, W1] = [lists:nth(1, lists:nth(1,FinalPushSumList)), lists:nth(2, lists:nth(1,FinalPushSumList))],
                    [S2, W2] = [lists:nth(1, lists:nth(2,FinalPushSumList)), lists:nth(2, lists:nth(2,FinalPushSumList))],
                    [S3, W3] = [lists:nth(1, lists:nth(3,FinalPushSumList)), lists:nth(2, lists:nth(3,FinalPushSumList))],
                    [S4, W4] = [lists:nth(1, lists:nth(4,FinalPushSumList)), lists:nth(2, lists:nth(4,FinalPushSumList))],
                    Diff1 = abs((S1/W1)-(S2/W2)),
                    Diff2 = abs((S2/W2)-(S3/W3)),
                    Diff3 = abs((S3/W3)-(S4/W4)),
                    MaxDiff = math:pow(10,-10),
                    if
                        (Diff1 < MaxDiff) and (Diff2 < MaxDiff) and (Diff3 < MaxDiff) ->        
                            if
                                Next =/= x ->
                                    NextNodeName = "node_"++integer_to_list(Next),
                                    {ok, NextNode} = dict:find(NextNodeName, NodeList),
                                    NextNode ! {updateprevious, Previous};
                                true ->
                                    ok
                            end,
                            if
                                Previous =/= x ->
                                    PreviousNodeName = "node_"++integer_to_list(Previous),
                                    {ok, PreviousNode} = dict:find(PreviousNodeName, NodeList),
                                    PreviousNode ! {updatenext, Next};
                                true ->
                                    ok
                            end,
                            nodeList ! {deletefromnodelist, NodeNumber},
                            io:format("Node: ~w heard rumour ~w times. *Node Terminated* ~n",[NodeNumber, Count + 1]),
                            exit(normal);
                        true ->
                            ok
                    end;
                true ->
                    FinalPushSumList = UpdatedPushSumList
            end,
            linePushSum(NodeNumber, Previous, Next, Count + 1, NodeList, FinalPushSumList)
    after 100 ->
        if 
            Count > 0 ->
                ok;
            true ->
                linePushSum(NodeNumber, Previous, Next, Count, NodeList, PushSumList)
        end,
        nodeList ! {getnodelist, self()},
        receive
            {updatenodenumberlist, UpdatedNodeNumberList} ->
                AllActiveNodeList = UpdatedNodeNumberList
        after 100 ->
            io:format("Main Node List Not Responding~n", []),
            AllActiveNodeList = [],
            exit(timeout)
        end,
        PreviousActive = lists:member(Previous, AllActiveNodeList),
        NextActive = lists:member(Next, AllActiveNodeList),
        if
            (Previous == x) or not PreviousActive ->
                UpdatedPrevious = x,
                PreviousNodeList = [];
            true ->
                UpdatedPrevious = Previous,
                PreviousNodeList = [Previous]
        end,
        if
            (Next == x) or not NextActive ->
                UpdatedNext = x,
                NextNodeList = [];
            true ->
                UpdatedNext = Next,
                NextNodeList = [Next]
        end,
        NeighborNodeList = lists:append(PreviousNodeList, NextNodeList),
        [S, W] = lists:last(PushSumList),
        UpdatedPushSumList = lists:append(lists:delete([S,W],PushSumList),[[S/2,W/2]]),
        if
            length(NeighborNodeList) == 0 ->
                nodeList ! {deletefromnodelist, NodeNumber},
                io:format("Node : ~w heard the rumour ~w times. *Terminating since no neighbours are active* ~n",[NodeNumber,Count]),
                exit(normal);
            true ->
                SendNodeNumber = lists:nth(rand:uniform(length(NeighborNodeList)), NeighborNodeList),
                SendNodeName = "node_"++integer_to_list(SendNodeNumber),
                {ok, SendNode} = dict:find(SendNodeName, NodeList),
                SendNode ! {get_gossip, [S/2, W/2]},
                linePushSum(NodeNumber, Previous, Next, Count, NodeList, UpdatedPushSumList)
        end
    end.

twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList) ->
    receive
        {updateList, UpdatedNodeList} ->
            twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, UpdatedNodeList, Type, PushSumList);
        {updatetop, UpdatedTop} ->
            twoDPushSum(I, J, N, UpdatedTop, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updatebottom, UpdatedBottom} ->
            twoDPushSum(I, J, N, Top, UpdatedBottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updateleft, UpdatedLeft} ->
            twoDPushSum(I, J, N, Top, Bottom, UpdatedLeft, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updateright, UpdatedRight} ->
            twoDPushSum(I, J, N, Top, Bottom, Left, UpdatedRight, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updatetopleft, UpdatedTopLeft} ->
            twoDPushSum(I, J, N, Top, Bottom, Left, Right, UpdatedTopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updatetopright, UpdatedTopRight} ->
            twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, UpdatedTopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updatebottomleft, UpdatedBottomLeft} ->
            twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, UpdatedBottomLeft, BottomRight, Count, NodeList, Type, PushSumList);
        {updatebottomright, UpdatedBottomRight} ->
            twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, UpdatedBottomRight, Count, NodeList, Type, PushSumList);
        {get_gossip, PushSumValue} ->
            LastPushSumValue = lists:last(PushSumList),
            NewS = (lists:nth(1,LastPushSumValue)+lists:nth(1,PushSumValue)),
            NewW = (lists:nth(2,LastPushSumValue)+lists:nth(2,PushSumValue)),
            UpdatedPushSumValue = [NewS,NewW],
            UpdatedPushSumList = lists:append(PushSumList, [UpdatedPushSumValue]),
            io:format("Node: (~w,~w) heard rumour ~w times.~n",[I, J, Count + 1]),
            if
                length(UpdatedPushSumList) > 4 ->
                    FinalPushSumList = lists:delete(lists:nth(1,UpdatedPushSumList),UpdatedPushSumList),
                    [S1, W1] = [lists:nth(1, lists:nth(1,FinalPushSumList)), lists:nth(2, lists:nth(1,FinalPushSumList))],
                    [S2, W2] = [lists:nth(1, lists:nth(2,FinalPushSumList)), lists:nth(2, lists:nth(2,FinalPushSumList))],
                    [S3, W3] = [lists:nth(1, lists:nth(3,FinalPushSumList)), lists:nth(2, lists:nth(3,FinalPushSumList))],
                    [S4, W4] = [lists:nth(1, lists:nth(4,FinalPushSumList)), lists:nth(2, lists:nth(4,FinalPushSumList))],
                    Diff1 = abs((S1/W1)-(S2/W2)),
                    Diff2 = abs((S2/W2)-(S3/W3)),
                    Diff3 = abs((S3/W3)-(S4/W4)),
                    MaxDiff = math:pow(10,-10),
                    if
                        (Diff1 < MaxDiff) and (Diff2 < MaxDiff) and (Diff3 < MaxDiff) ->
                            if
                                Top =/= [x,x] ->
                                    TopNodeName = "node_"++integer_to_list(lists:nth(1,Top))++"_"++integer_to_list(lists:nth(2,Top)),
                                    {ok, TopNode} = dict:find(TopNodeName, NodeList),
                                    TopNode ! {updatebottom, Bottom};
                                true ->
                                    ok
                            end,
                            if
                                Bottom =/= [x,x] ->
                                    BottomNodeName = "node_"++integer_to_list(lists:nth(1,Bottom))++"_"++integer_to_list(lists:nth(2,Bottom)),
                                    {ok, BottomNode} = dict:find(BottomNodeName, NodeList),
                                    BottomNode ! {updatetop, Top};
                                true ->
                                    ok
                            end,
                            if
                                Left =/= [x,x] ->
                                    LeftNodeName = "node_"++integer_to_list(lists:nth(1,Left))++"_"++integer_to_list(lists:nth(2,Left)),
                                    {ok, LeftNode} = dict:find(LeftNodeName, NodeList),
                                    LeftNode ! {updateright, Right};
                                true ->
                                    ok
                            end,
                            if
                                Right =/= [x,x] ->
                                    RightNodeName = "node_"++integer_to_list(lists:nth(1,Right))++"_"++integer_to_list(lists:nth(2,Right)),
                                    {ok, RightNode} = dict:find(RightNodeName, NodeList),
                                    RightNode ! {updateleft, Left};
                                true ->
                                    ok
                            end,
                            if
                                TopLeft =/= [x,x] ->
                                    TopLeftNodeName = "node_"++integer_to_list(lists:nth(1,TopLeft))++"_"++integer_to_list(lists:nth(2,TopLeft)),
                                    {ok, TopLeftNode} = dict:find(TopLeftNodeName, NodeList),
                                    TopLeftNode ! {updatebottomright, BottomRight};
                                true ->
                                    ok
                            end,
                            if
                                TopRight =/= [x,x] ->
                                    TopRightNodeName = "node_"++integer_to_list(lists:nth(1,TopRight))++"_"++integer_to_list(lists:nth(2,TopRight)),
                                    {ok, TopRightNode} = dict:find(TopRightNodeName, NodeList),
                                    TopRightNode ! {updatebottomleft, BottomLeft};
                                true ->
                                    ok
                            end,
                            if
                                BottomLeft =/= [x,x] ->
                                    BottomLeftNodeName = "node_"++integer_to_list(lists:nth(1,BottomLeft))++"_"++integer_to_list(lists:nth(2,BottomLeft)),
                                    {ok, BottomLeftNode} = dict:find(BottomLeftNodeName, NodeList),
                                    BottomLeftNode ! {updatetopright, TopRight};
                                true ->
                                    ok
                            end,
                            if
                                BottomRight =/= [x,x] ->
                                    BottomRightNodeName = "node_"++integer_to_list(lists:nth(1,BottomRight))++"_"++integer_to_list(lists:nth(2,BottomRight)),
                                    {ok, BottomRightNode} = dict:find(BottomRightNodeName, NodeList),
                                    BottomRightNode ! {updatetopleft, TopLeft};
                                true ->
                                    ok
                            end,
                            nodeList ! {deletefromnodelist, [I,J]},
                            io:format("Node : (~w,~w) heard the rumour ~w times. *Node Terminated* ~n",[I, J,Count + 1]),
                            exit(normal);
                        true ->
                            ok
                    end;
                true ->
                    FinalPushSumList = UpdatedPushSumList
            end,
            twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count + 1, NodeList, Type, FinalPushSumList)
    after 100 ->
        if 
            Count > 0 ->
                ok;
            true ->
                twoDPushSum(I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, Count, NodeList, Type, PushSumList)
        end,
        nodeList ! {getnodelist, self()},
        receive
            {updatenodenumberlist, UpdatedNodeNumberList} ->
                AllActiveNodeList = UpdatedNodeNumberList
        after 100 ->
            io:format("Main Node List Not Responding~n", []),
            AllActiveNodeList = [],
            exit(timeout)
        end,
        TopActive = lists:member(Top, AllActiveNodeList),
        BottomActive = lists:member(Bottom, AllActiveNodeList),
        LeftActive = lists:member(Left, AllActiveNodeList),
        RightActive = lists:member(Right, AllActiveNodeList),
        TopLeftActive = lists:member(TopLeft, AllActiveNodeList),
        TopRightActive = lists:member(TopRight, AllActiveNodeList),
        BottomLeftActive = lists:member(BottomLeft, AllActiveNodeList),
        BottomRightActive = lists:member(BottomRight, AllActiveNodeList),
        if
            (Top == [x,x]) or not TopActive ->
                UpdatedTop = [x,x],
                TopNodeList = [];
            true ->
                UpdatedTop = Top,
                TopNodeList = [Top]
        end,
        if
            (Bottom == [x,x]) or not BottomActive ->
                UpdatedBottom = [x,x],
                BottomNodeList = [];
            true ->
                UpdatedBottom = Bottom,
                BottomNodeList = [Bottom]
        end,
        if
            (Left == [x,x]) or not LeftActive ->
                UpdatedLeft = [x,x],
                LeftNodeList = [];
            true ->
                UpdatedLeft = Left,
                LeftNodeList = [Left]
        end,
        if
            (Right == [x,x]) or not RightActive ->
                UpdatedRight = [x,x],
                RightNodeList = [];
            true ->
                UpdatedRight = Right,
                RightNodeList = [Right]
        end,
        if
            (TopLeft == [x,x]) or not TopLeftActive ->
                UpdatedTopLeft = [x,x],
                TopLeftNodeList = [];
            true ->
                UpdatedTopLeft = TopLeft,
                TopLeftNodeList = [TopLeft]
        end,
        if
            (TopRight == [x,x]) or not TopRightActive ->
                UpdatedTopRight = [x,x],
                TopRightNodeList = [];
            true ->
                UpdatedTopRight = TopRight,
                TopRightNodeList = [TopRight]
        end,
        if
            (BottomLeft == [x,x]) or not BottomLeftActive ->
                UpdatedBottomLeft = [x,x],
                BottomLeftNodeList = [];
            true ->
                UpdatedBottomLeft = BottomLeft,
                BottomLeftNodeList = [BottomLeft]
        end,
        if
            (BottomRight == [x,x]) or not BottomRightActive ->
                UpdatedBottomRight = [x,x],
                BottomRightNodeList = [];
            true ->
                UpdatedBottomRight = BottomRight,
                BottomRightNodeList = [BottomRight]
        end,
        if
            Type == imperfect ->
                ActiveNodeList = lists:delete([I,J], AllActiveNodeList),
                RandomNode = lists:nth(rand:uniform(length(ActiveNodeList)), ActiveNodeList),
                RandomNodeList = [RandomNode];
            Type == grid ->
                RandomNodeList = []
        end,
        NeighborNodeList = lists:append([TopNodeList, BottomNodeList, LeftNodeList, RightNodeList, TopLeftNodeList, TopRightNodeList, BottomLeftNodeList, BottomRightNodeList, RandomNodeList]),
        [S, W] = lists:last(PushSumList),
        UpdatedPushSumList = lists:append(lists:delete([S,W],PushSumList),[[S/2,W/2]]),
        if
            length(NeighborNodeList) ==0 ->
                nodeList ! {deletefromnodelist, [I,J]},
                io:format("Node : (~w,~w) heard the rumour ~w times. *Terminating since no neighbours are active*~n",[I, J, Count]),
                exit(normal);
            true ->
                SendNodeNumber = lists:nth(rand:uniform(length(NeighborNodeList)), NeighborNodeList),
                SendNodeName = "node_"++integer_to_list(lists:nth(1,SendNodeNumber))++"_"++integer_to_list(lists:nth(2,SendNodeNumber)),
                {ok, SendNode} = dict:find(SendNodeName, NodeList),
                SendNode ! {get_gossip, [S/2, W/2]},
                twoDPushSum(I, J, N, UpdatedTop, UpdatedBottom, UpdatedLeft, UpdatedRight, UpdatedTopLeft, UpdatedTopRight, UpdatedBottomLeft, UpdatedBottomRight, Count, NodeList, Type, UpdatedPushSumList)
        end
    end.

fullPushSum(NodeNumber, Count, NodeList, PushSumList) ->
    receive
        {updateList, UpdatedNodeList} ->
            fullPushSum(NodeNumber, Count, UpdatedNodeList, PushSumList);
        {get_gossip, PushSumValue} ->
            LastPushSumValue = lists:last(PushSumList),
            NewS = (lists:nth(1,LastPushSumValue)+lists:nth(1,PushSumValue)),
            NewW = (lists:nth(2,LastPushSumValue)+lists:nth(2,PushSumValue)),
            UpdatedPushSumValue = [NewS,NewW],
            UpdatedPushSumList = lists:append(PushSumList, [UpdatedPushSumValue]),
            io:format("Node : ~w heard the rumour ~w times. ~n",[NodeNumber, Count + 1]),
            if
                length(UpdatedPushSumList) > 4 ->
                    FinalPushSumList = lists:delete(lists:nth(1,UpdatedPushSumList),UpdatedPushSumList),
                    [S1, W1] = [lists:nth(1, lists:nth(1,FinalPushSumList)), lists:nth(2, lists:nth(1,FinalPushSumList))],
                    [S2, W2] = [lists:nth(1, lists:nth(2,FinalPushSumList)), lists:nth(2, lists:nth(2,FinalPushSumList))],
                    [S3, W3] = [lists:nth(1, lists:nth(3,FinalPushSumList)), lists:nth(2, lists:nth(3,FinalPushSumList))],
                    [S4, W4] = [lists:nth(1, lists:nth(4,FinalPushSumList)), lists:nth(2, lists:nth(4,FinalPushSumList))],
                    Diff1 = abs((S1/W1)-(S2/W2)),
                    Diff2 = abs((S2/W2)-(S3/W3)),
                    Diff3 = abs((S3/W3)-(S4/W4)),
                    MaxDiff = math:pow(10,-10),
                    if
                        (Diff1 < MaxDiff) and (Diff2 < MaxDiff) and (Diff3 < MaxDiff) ->  
                            nodeList ! {deletefromnodelist, NodeNumber},
                            io:format("Node: ~w heard the rumour ~w times. *Node Terminated*~n",[NodeNumber, Count + 1]),
                            exit(normal);
                        true ->
                            ok
                    end;
                true ->
                    FinalPushSumList = UpdatedPushSumList
            end,
            fullPushSum(NodeNumber, Count + 1, NodeList, FinalPushSumList)
    after 100 ->
        if 
            Count > 0 ->
                ok;
            true ->
                fullPushSum(NodeNumber, Count, NodeList, PushSumList)
        end,
        nodeList ! {getnodelist, self()},
        receive
            {updatenodenumberlist, UpdatedNodeNumberList} ->
                NeighborNodeList = lists:delete(NodeNumber, UpdatedNodeNumberList)
        after 100 ->
            io:format("Main Node List Not Responding~n", []),
            NeighborNodeList = [],
            exit(timeout)
        end,
        [S, W] = lists:last(PushSumList),
        UpdatedPushSumList = lists:append(lists:delete([S,W],PushSumList),[[S/2,W/2]]),
        if
            length(NeighborNodeList) == 0 ->
                nodeList ! {deletefromnodelist, NodeNumber},
                io:format("Node : ~w heard the rumour ~w times. *Terminating since no neighbours are active* ~n",[Count, NodeNumber]),
                exit(normal);
            true ->
                SendNodeNumber = lists:nth(rand:uniform(length(NeighborNodeList)), NeighborNodeList),
                SendNodeName = "node_"++integer_to_list(SendNodeNumber),
                {ok, SendNode} = dict:find(SendNodeName, NodeList),
                SendNode ! {get_gossip, [S/2, W/2]},
                fullPushSum(NodeNumber, Count, NodeList, UpdatedPushSumList)
        end
    end.


updateNetwork(0, NodeList) ->
    NodeList;
updateNetwork(N, NodeList) ->
    NodeName = "node_"++integer_to_list(N),
    {ok, Node} = dict:find(NodeName, NodeList),
    Node ! {updateList, NodeList},
    updateNetwork(N - 1, NodeList).

updateNetwork(I, J, N, NodeList) ->
    if 
        I =< N ->
            if
                J =< N ->
                    NodeName = "node_"++integer_to_list(I)++"_"++integer_to_list(J),
                    {ok, Node} = dict:find(NodeName, NodeList),
                    Node ! {updateList, NodeList},
                    updateNetwork(I, J + 1, N, NodeList);
                true ->
                    updateNetwork(I + 1, 1, N, NodeList)
            end;
        true ->
            NodeList
    end.

createNetwork(0, NumberOfNodes, NodeList, _, _) ->
    updateNetwork(NumberOfNodes, NodeList);
createNetwork(N, NumberOfNodes, NodeList, Topology, Algorithm) ->
    if
        Topology == line ->
            if 
                Algorithm == gossip ->
                    if 
                        N == NumberOfNodes ->
                            NewNode = spawn(project2, lineGossip, [N, N - 1, x, 0, NodeList]);
                        N == 1 ->
                            NewNode = spawn(project2, lineGossip, [N, x, N + 1, 0, NodeList]);
                        true ->
                            NewNode = spawn(project2, lineGossip, [N, N - 1, N + 1, 0, NodeList])
                    end;
                Algorithm == pushsum ->
                    if 
                        N == NumberOfNodes ->
                            NewNode = spawn(project2, linePushSum, [N, N - 1, x, 0, NodeList, [[N, 1]]]);
                        N == 1 ->
                            NewNode = spawn(project2, linePushSum, [N, x, N + 1, 0, NodeList, [[N, 1]]]);
                        true ->
                            NewNode = spawn(project2, linePushSum, [N, N - 1, N + 1, 0, NodeList, [[N, 1]]])
                    end
            end;
        Topology == full ->
            if 
                Algorithm == gossip ->
                    NewNode = spawn(project2, fullGossip, [N, 0, NodeList]);
                Algorithm == pushsum ->
                    NewNode = spawn(project2, fullPushSum, [N, 0, NodeList, [[N, 1]]])
            end
    end,
    NewNodeList = dict:store("node_"++integer_to_list(N), NewNode, NodeList),
    createNetwork(N - 1, NumberOfNodes, NewNodeList, Topology, Algorithm).

createNetwork(I, J, N, NodeList, Topology, Algorithm) ->
    if 
        I =< N ->
            if
                J =< N ->
                    if 
                        I == 1 ->
                            Top = [x,x];
                        true ->
                            Top = [I - 1, J]
                    end,
                    if 
                        I == N ->
                            Bottom = [x,x];
                        true ->
                            Bottom = [I + 1, J]
                    end,
                    if 
                        J == 1 ->
                            Left = [x,x];
                        true ->
                            Left = [I, J - 1]
                    end,
                    if 
                        J == N ->
                            Right = [x,x];
                        true ->
                            Right = [I, J + 1]
                    end,
                    if
                        (Top == [x,x]) or (Left == [x,x]) ->
                            TopLeft = [x,x];
                        true ->
                            TopLeft = [I - 1, J - 1]
                    end,
                    if
                        (Top == [x,x]) or (Right == [x,x]) ->
                            TopRight = [x,x];
                        true ->
                            TopRight = [I - 1, J + 1]
                    end,
                    if
                        (Bottom == [x,x]) or (Left == [x,x]) ->
                            BottomLeft = [x,x];
                        true ->
                            BottomLeft = [I + 1, J - 1]
                    end,
                    if
                        (Bottom == [x,x]) or (Right == [x,x]) ->
                            BottomRight = [x,x];
                        true ->
                            BottomRight = [I + 1, J + 1]
                    end,
                    if
                        Algorithm == gossip ->
                            NewNode = spawn(project2, twoDGossip, [I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, 0, NodeList, Topology]);
                        Algorithm == pushsum ->
                            S = (I - 1)*N + J,
                            NewNode = spawn(project2, twoDPushSum, [I, J, N, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight, 0, NodeList, Topology, [[S,1]]])
                    end,
                    NewNodeList = dict:store("node_"++integer_to_list(I)++"_"++integer_to_list(J), NewNode, NodeList),
                    createNetwork(I, J + 1, N, NewNodeList, Topology, Algorithm);
                true ->
                    NewNodeList = NodeList,
                    createNetwork(I + 1, 1, N, NewNodeList, Topology, Algorithm)
            end;
        true ->
            updateNetwork(1, 1, N, NodeList)
    end.
nodeList(NodeNumberList) ->
    receive
        {getnodelist, From} ->
            From ! {updatenodenumberlist, NodeNumberList},
            nodeList(NodeNumberList);
        {deletefromnodelist, FromNodeNumber} ->
            UpdatedNodeNumberList = lists:delete(FromNodeNumber, NodeNumberList),
            if
                length(UpdatedNodeNumberList) == 0 ->
                    io:format("Main Node Terminated~n",[]),
                    {_,Time} = statistics(wall_clock),
                    io:format("The nodes converged in ~p ms~n", [Time]),
                    exit(normal);
                true ->
                    ok
            end,
            nodeList(UpdatedNodeNumberList)
    end.

getNodeList(I, J, N, NodeList) ->
    if 
        I =< N ->
            if
                J =< N ->
                    UpdatedNodeList = lists:append(NodeList, [[I,J]]),
                    getNodeList(I, J + 1, N, UpdatedNodeList);
                true ->
                    getNodeList(I + 1, 1, N, NodeList)
            end;
        true ->
            NodeList
    end.

main(NumberOfNodes, Topology, Algorithm) ->
    % {ok, NumNodes} = io:read("Enter number of nodes: "),
    % {ok, Topology} = io:read("Enter topology (full | grid | line | imperfect): "),
    % {ok, Algorithm} = io:read("Enter algorithm (gossip | pushsum):"),
    TopologyIsSquare = lists:member(Topology, [grid, imperfect]),
    TopologyIsLiner = lists:member(Topology, [full, line]),
    if
        TopologyIsSquare ->
            Sqrt = round(math:ceil(math:sqrt(NumberOfNodes))),
            NodeList = createNetwork(1, 1, Sqrt, dict:new(), Topology, Algorithm),
            register(nodeList, spawn(project2, nodeList, [getNodeList(1, 1, Sqrt, [])])),
            SeedNodeI = rand:uniform(Sqrt),
            SeedNodeJ = rand:uniform(Sqrt),
            SeedNodeName = "node_"++integer_to_list(SeedNodeI)++"_"++integer_to_list(SeedNodeJ),
            io:format("Starting Node: ~p~n", [SeedNodeName]),
            {ok, SeedNode} = dict:find(SeedNodeName, NodeList),
            if
                Algorithm == gossip ->
                    SeedNode ! get_gossip;
                Algorithm == pushsum ->
                    PushSumS = ((SeedNodeI - 1)*Sqrt) + SeedNodeJ,
                    SeedNode ! {get_gossip, [PushSumS, 1]}
            end;
        TopologyIsLiner ->
            NodeList = createNetwork(NumberOfNodes, NumberOfNodes, dict:new(), Topology, Algorithm),
            register(nodeList, spawn(project2, nodeList, [lists:seq(1, NumberOfNodes)])),
            SeedNodeNumber = rand:uniform(NumberOfNodes),
            SeedNodeName = "node_"++integer_to_list(SeedNodeNumber),
            io:format("Starting Node: ~p~n", [SeedNodeName]),
            {ok, SeedNode} = dict:find(SeedNodeName, NodeList),
            if
                Algorithm == gossip ->
                    SeedNode ! get_gossip;
                Algorithm == pushsum ->
                    SeedNode ! {get_gossip, [SeedNodeNumber, 1]}
            end
    end,
    statistics(wall_clock),
    io:format("Node List : ~p ~w ~w~n", [dict:to_list(NodeList), Topology, Algorithm]).
