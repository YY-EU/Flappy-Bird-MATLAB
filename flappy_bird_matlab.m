function flappy_bird_matlab
    %=============================
    % Flappy Bird in MATLAB
    %=============================

    % Game parameters
    game.pos = 200;           % bird y position
    game.vel = 0;             % bird velocity
    game.g = -0.5;            % gravity
    game.flap = 8;            % flap strength
    game.state = 'ready';     % 'ready','playing','over'
    game.pipes = [];          % [x, gapY, scored]
    game.score = 0;           
    game.best = 0;            
    game.tick = 0;            

    % Figure setup
    fig = figure('Name','Flappy Bird MATLAB','NumberTitle','off', ...
                 'Color','#87CEEB','KeyPressFcn',@keyDown);

    axis([0 400 0 400]);
    axis manual off;
    hold on;

    % Main game loop
    while ishandle(fig)
        cla; % clear axes
        game.tick = game.tick + 1;

        %=====================
        % Draw bird
        %=====================
        rectangle('Position',[50 game.pos 20 20], ...
                  'FaceColor','#FFD700','Curvature',[1 1]);

        %=====================
        % Game states
        %=====================
        if strcmp(game.state,'playing')
            % Physics update
            game.vel = game.vel + game.g;
            game.pos = game.pos + game.vel;

            % Spawn pipes every 100 ticks
            if mod(game.tick,100) == 0
                gapY = 100 + rand*200;
                game.pipes(end+1,:) = [400 gapY 0]; % x, gapY, scored
            end

            % Move pipes left (only if not empty)
            if ~isempty(game.pipes)
                game.pipes(:,1) = game.pipes(:,1) - 2;
                % Remove offscreen pipes
                game.pipes(game.pipes(:,1)<-60,:) = [];
            end

            % Draw pipes
            gap = 100;
            for i = 1:size(game.pipes,1)
                x = game.pipes(i,1); 
                gapY = game.pipes(i,2);

                % Top pipe
                rectangle('Position',[x 0 60 gapY-gap/2], ...
                          'FaceColor','#228B22');
                % Bottom pipe
                rectangle('Position',[x gapY+gap/2 60 400-(gapY+gap/2)], ...
                          'FaceColor','#228B22');

                % Scoring
                if game.pipes(i,1)+60 < 50 && game.pipes(i,3)==0
                    game.score = game.score + 1;
                    game.pipes(i,3) = 1;
                end

                % Collision detection
                if 50+20 > x && 50 < x+60
                    if game.pos < gapY-gap/2 || game.pos+20 > gapY+gap/2
                        game.state = 'over';
                        if game.score > game.best
                            game.best = game.score;
                        end
                    end
                end
            end

            % Ground / ceiling check
            if game.pos <= 0 || game.pos >= 380
                game.state = 'over';
                if game.score > game.best
                    game.best = game.score;
                end
            end
        end

        %=====================
        % Display text
        %=====================
        if strcmp(game.state,'ready')
            text(200,200,'Press W to Start','FontSize',14, ...
                 'HorizontalAlignment','center');
        elseif strcmp(game.state,'playing')
            text(200,380,sprintf('Score: %d',game.score), ...
                 'FontSize',14,'HorizontalAlignment','center');
        elseif strcmp(game.state,'over')
            text(200,250,'GAME OVER','FontSize',16, ...
                 'HorizontalAlignment','center','Color','red');
            text(200,220,sprintf('Score: %d  Best: %d', ...
                 game.score,game.best), ...
                 'FontSize',12,'HorizontalAlignment','center');
            text(200,190,'Press R to Restart','FontSize',12, ...
                 'HorizontalAlignment','center');
        end

        drawnow;
        pause(0.02);
    end

    %=====================
    % Key handler
    %=====================
    function keyDown(~,event)
        switch event.Key
            case 'w' % flap / start
                if strcmp(game.state,'ready')
                    game.state = 'playing';
                    game.score = 0;
                    game.pipes = [];
                    game.pos = 200;
                    game.vel = 0;
                    game.tick = 0;
                elseif strcmp(game.state,'playing')
                    game.vel = game.flap;
                end
            case 'a' % move left (small shift)
                if strcmp(game.state,'playing')
                    game.pos = game.pos - 5;
                end
            case 's' % move down (fast)
                if strcmp(game.state,'playing')
                    game.pos = game.pos - 15;
                end
            case 'd' % move right (small up shift)
                if strcmp(game.state,'playing')
                    game.pos = game.pos + 5;
                end
            case 'r' % restart after game over
                if strcmp(game.state,'over')
                    game.state = 'ready';
                    game.pos = 200;
                    game.vel = 0;
                    game.pipes = [];
                    game.score = 0;
                    game.tick = 0;
                end
        end
    end
end

           
           
   
              


