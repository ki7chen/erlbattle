-module(englandArmy).
-include("schema.hrl").
-export([run/2]).

run(Channel, Side) ->
    
	%% 可以不捕获，直接由父进程杀掉
	process_flag(trap_exit, true),
	
	loop(Channel, Side).

loop(Channel, Side) ->
	
	Army = [1,2,3,4,5,6,7,8,9,10],
	
	lists:foreach(
		fun(Soldier) ->   % 一直朝前， 直到碰到人，然后开始砍	
			case someoneAhead(Soldier,Side) of
				true ->
					Channel!{command,"attack",Soldier,0};
				false ->
					Channel!{command,"forward",Soldier,0};
				_ ->
					none
			end
		end,
		Army),
	
	%% 等待结束指令，其实这个程序不需要做任何善后，只是作为例子提供给大家模仿
	receive
		%% 结束战斗，可以做一些收尾工作后退出，或者什么都不做
		%% 这个消息不是必须处理的
		{'EXIT',_FROM, finish} ->  
			io:format("England Army Go Back To Castle ~n",[]);
					
		_ ->
			loop(Channel, Side)
			
	after 100 -> 
			loop(Channel, Side)
			
	end.


%% 计算某个角色前面是否有人
someoneAhead(SoldierId,Side) ->
	
	case battlefield:get_soldier(SoldierId,Side) of
		
		none ->  % 角色不存在（已经挂掉了）
			none;
		
		Soldier when is_record(Soldier,soldier) ->  % 找到角色

			Position = erlbattle:calcDestination(Soldier#soldier.position, Soldier#soldier.facing, 1),

			case battlefield:get_soldier_by_position(Position) of 
				none ->  		%前面没人
					false;
				_Found ->		%有人
					true
			end;
		_->
			none
	end.
					
			
			
	



	