% Flappy Bird game in MATLAB with space to jump, P to pause, R to restart
function flappy_bird()
    % Initialize figure and axes
    fig = figure('KeyPressFcn', @keyPress, 'CloseRequestFcn', @closeGame);
    ax = axes('XLim', [0 100], 'YLim', [0 100], 'NextPlot', 'add');
    axis off;
    
    % Game parameters
    birdY = 50; % Bird's initial y-position
    birdVel = 0; % Bird's vertical velocity
    gravity = -0.1; % Gravity acceleration
    flapStrength = 1; % Velocity boost when flapping
    pipeSpeed = -2; % Pipe movement speed
    pipeGap = 30; % Gap size between pipes
    pipeWidth = 10; % Pipe width
    pipeSpacing = 60; % Distance between pipes
    pipes = [100 50; 160 50]; % Pipe positions [x, gap center y]
    score = 0; % Player score
    gameOver = false; % Game state
    paused = false; % Pause state
    
    % Plot bird (blue circle)
    bird = plot(ax, 20, birdY, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    
    % Plot pipes (green rectangles)
    pipePlots = gobjects(2, 2); % Array to store pipe plot handles
    for i = 1:2
        pipePlots(i, 1) = rectangle(ax, 'Position', [pipes(i, 1), 0, pipeWidth, pipes(i, 2) - pipeGap/2], ...
            'FaceColor', 'g');
        pipePlots(i, 2) = rectangle(ax, 'Position', [pipes(i, 1), pipes(i, 2) + pipeGap/2, pipeWidth, 100], ...
            'FaceColor', 'g');
    end
    
    % Score display
    scoreText = text(ax, 10, 90, sprintf('Score: %d', score), 'FontSize', 12);
    
    % Pause text (initially invisible)
    pauseText = text(ax, 50, 50, 'Paused', 'FontSize', 20, 'HorizontalAlignment', 'center', ...
        'Color', 'b', 'Visible', 'off');
    
    % Game over text (initially invisible)
    gameOverText = text(ax, 50, 50, 'Game Over', 'FontSize', 20, 'HorizontalAlignment', 'center', ...
        'Color', 'r', 'Visible', 'off');
    
    % Game loop using timer
    t = timer('TimerFcn', @updateGame, 'Period', 0.05, 'ExecutionMode', 'fixedRate', 'BusyMode', 'queue');
    start(t);
    
    % Nested function to handle key press
    function keyPress(~, event)
        if strcmp(event.Key, 'space') && ~gameOver && ~paused
            birdVel = flapStrength; % Flap upward
        elseif strcmp(event.Key, 'p') && ~gameOver
            paused = ~paused; % Toggle pause
            set(pauseText, 'Visible', onOff(paused));
        elseif strcmp(event.Key, 'r') && gameOver
            restartGame(); % Restart game
        end
    end
    
    % Nested function to update game state
    function updateGame(~, ~)
        if gameOver || paused
            return;
        end
        
        % Update bird position
        birdVel = birdVel + gravity;
        birdY = birdY + birdVel;
        set(bird, 'YData', birdY);
        
        % Update pipe positions
        pipes(:, 1) = pipes(:, 1) + pipeSpeed;
        
        % Move pipes back to the right when they go off-screen
        for i = 1:2
            if pipes(i, 1) < -pipeWidth
                pipes(i, 1) = pipes(i, 1) + pipeSpacing * 2;
                pipes(i, 2) = 30 + 40*rand; % Random gap center between 30 and 70
                score = score + 1; % Increment score
                set(scoreText, 'String', sprintf('Score: %d', score));
            end
        end
        
        % Update pipe plots
        for i = 1:2
            set(pipePlots(i, 1), 'Position', [pipes(i, 1), 0, pipeWidth, pipes(i, 2) - pipeGap/2]);
            set(pipePlots(i, 2), 'Position', [pipes(i, 1), pipes(i, 2) + pipeGap/2, pipeWidth, 100]);
        end
        
        % Check for collisions
        if birdY <= 0 || birdY >= 100
            endGame();
            return;
        end
        
        for i = 1:2
            if 20 >= pipes(i, 1) && 20 <= pipes(i, 1) + pipeWidth && ...
                    (birdY < pipes(i, 2) - pipeGap/2 || birdY > pipes(i, 2) + pipeGap/2)
                endGame();
                return;
            end
        end
    end
    
    % Nested function to end the game
    function endGame()
        gameOver = true;
        set(gameOverText, 'Visible', 'on');
        stop(t);
    end
    
    % Nested function to restart the game
    function restartGame()
        % Reset game parameters
        birdY = 50;
        birdVel = 0;
        pipes = [100 50; 160 50];
        score = 0;
        gameOver = false;
        paused = false;
        
        % Reset visuals
        set(bird, 'YData', birdY);
        set(scoreText, 'String', sprintf('Score: %d', score));
        set(gameOverText, 'Visible', 'off');
        set(pauseText, 'Visible', 'off');
        for i = 1:2
            set(pipePlots(i, 1), 'Position', [pipes(i, 1), 0, pipeWidth, pipes(i, 2) - pipeGap/2]);
            set(pipePlots(i, 2), 'Position', [pipes(i, 1), pipes(i, 2) + pipeGap/2, pipeWidth, 100]);
        end
        
        % Restart timer
        start(t);
    end
    
    % Nested function to convert boolean to 'on'/'off'
    function str = onOff(val)
        if main
            str = 'on';
        else
            str = 'off';
        end
    end
    
    % Nested function to close the game
    function closeGame(~, ~)
        stop(t);
        delete(t);
        delete(fig);
    end
end