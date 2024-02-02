%% Short script from my blog post on Memetic Theory:
% how increased inter-human communication bandwidth can affect Memetic
% diversity. This is just an overly simple model that makes a simple
% point: the more we are connected, the more memes have to compete with
% other memes for the same attention budgets. This selects for more
% attention grabbing memes.
% Author: Oscar Savolainen


    close all
    clearvars
    connected = 1;
    rng(1);

    J = 5; % nb of memes per kingdom
    N = 10; % nb of people per kingdom
    nb_of_kingdoms = 4;

    attention_grab = rand(1,nb_of_kingdoms*J); % how much attention each meme grabs
%    attention_budget = rand(nb_of_kingdoms*N,1); % the attention budget of each person
    spread_thresh = rand(nb_of_kingdoms*N,1); % the threshold for how much each person needs to believe a meme to spread it
    bias = rand(nb_of_kingdoms*N,1)*0.5; % ho much each person is biased towards their own ideas


    % Original connection matrix and meme-person indicator fucntion
    connectivity_matrix = zeros(nb_of_kingdoms*N);
    mask_person_meme = false(nb_of_kingdoms*N,nb_of_kingdoms*J);
    for k = 1:nb_of_kingdoms
        c = (k-1)*N+1:k*N;
        d = (k-1)*J+1:k*J;
        connectivity_matrix(c,c) = rand(N);
        mask_person_meme(c,d) = true;
    end
    connectivity_matrix(logical(eye(nb_of_kingdoms*N))) = 1;

    % After increased connection
    connectivity_matrix_global = 1/4*rand(nb_of_kingdoms*N);
    mask_connectivity = connectivity_matrix>0; % if connections are available
    connectivity_matrix_global(mask_connectivity) = connectivity_matrix(mask_connectivity);

    % Initialising how present each meme is
    meme_presence(1,:,:) = zeros(nb_of_kingdoms*N,nb_of_kingdoms*J);
    meme_presence_init = rand(nb_of_kingdoms*N,nb_of_kingdoms*J);
    meme_presence_init(~mask_person_meme) = 0; % set all memes absent from a kingdom to zero
    meme_presence(1,:,:) = meme_presence_init;

    % Plot connectivity matrices
    figure
    plot_Spectrogram(connectivity_matrix,1:4*N,1:4*N,'linear')
    title('Connectivity matrix at time step 1-100'); ylabel('Person'); xlabel('Person')
    figure
    plot_Spectrogram(connectivity_matrix_global,1:4*N,1:4*N,'linear')
    title('Connectivity matrix after time step 100'); ylabel('Person'); xlabel('Person')


    % Plot Meme Map at time step 1
    figure
    plot_Spectrogram(squeeze(meme_presence(1,:,:)),1:nb_of_kingdoms*J,1:nb_of_kingdoms*N,'linear');
    title(['Time step ',num2str(1)])
    ylabel('Person'); xlabel('Meme')

    for i = 2:250

        if i > 100 % after time step 100, we connect the kingdoms
            connected = 2;
        end

        crossed_thresh = squeeze(meme_presence(i-1,:,:))>spread_thresh; % does one believe the meme enough to spread it
        meme_sharing = crossed_thresh .* attention_grab; % how many people spread the meme times how attention grabbing the meme is
        idea_generation = rand(nb_of_kingdoms*N,nb_of_kingdoms*J)*0.1; % occasionally the memes experience some resurgence in individuals, for no reason
        idea_generation(~mask_person_meme) = 0;
        meme_sharing = meme_sharing + idea_generation; % low level noise, some ideas pop back up 

        if connected == 1 % if kingdoms are seperated
            connectivity_temp = binornd(ones(nb_of_kingdoms*N),connectivity_matrix); % the connectivity at this time step. Each person's likelihood of interacting with another person at any time step depends on their connection, given by the connectivity matrix.
        elseif connected == 2 % situation where bandwidth is increased, kingdoms are connected
            connectivity_temp = binornd(ones(nb_of_kingdoms*N),connectivity_matrix_global); % the connectivity at this time step    
        end
        communicated_memes = connectivity_temp * meme_sharing; % how much each meme is received per person

        % Each meme is taken on board linearly to how often it is
        % encountered, minus the effects of personal bias for their own
        % ideas
        communicated_memes = communicated_memes./sum(communicated_memes,2); % scale to sum to 1, since that is each person's attention budget
        communicated_memes(isnan(communicated_memes)) = 0; % if Nan (for some reason), set to zero.

        % How the presence of the memes get updated at each time step
        meme_presence(i,:,:) = squeeze(meme_presence(i-1,:,:)).*bias + communicated_memes.*(1-bias); % how much the beliefs of each person get updated depends on how resistant they are to changing their ideas (bias)

        if rem(i,50) == 0
            figure
            plot_Spectrogram(squeeze(meme_presence(i,:,:)),1:nb_of_kingdoms*J,1:nb_of_kingdoms*N,'linear');
            title(['Time step ',num2str(i),' - Meme map'])
            ylabel('Person'); xlabel('Meme')
        end
    end
    figure, bar(attention_grab)
    title('Instrinsic attention grabbing ability of each meme')
    corr(sum(squeeze(meme_presence(i,:,:)))',attention_grab','Type','Spearman')

    % Plot Meme Map (t = 250), and attention grabbing of eahc meme, for comparison
    figure, subplot(2,1,1)
    plot_Spectrogram(squeeze(meme_presence(i,:,:)),1:nb_of_kingdoms*J,1:nb_of_kingdoms*N,'linear');
    title(['Time step ',num2str(i),' - Meme map'])
    ylabel('Person'); xlabel('Meme')
    xlim([1 20])
    subplot(2,1,2)
    bar(attention_grab)
    ylabel(['Attention grabbing',newline,'ability'])
    xlabel('Meme')
    title('Instrinsic attention grabbing ability of each meme')
    xlim([0.5 19.5])

    % Plot Meme Map (t = 100), and attention grabbing of eahc meme, for comparison
    figure, subplot(2,1,1)
    plot_Spectrogram(squeeze(meme_presence(100,:,:)),1:nb_of_kingdoms*J,1:nb_of_kingdoms*N,'linear');
    title(['Time step ',num2str(100),' - Meme map'])
    ylabel('Person'); xlabel('Meme')
    xlim([1 20])
    subplot(2,1,2)
    bar(attention_grab)
    ylabel(['Attention grabbing',newline,'ability'])
    xlabel('Meme')
    title('Instrinsic attention grabbing ability of each meme')
    xlim([0.5 19.5])
