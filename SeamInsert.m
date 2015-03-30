function [] = SeamInsert( image, desired_height, desired_width )
%   This function takes 3 parameters
%       1. an image as a string
%       2. the desired height of your image
%       3. the desired width of your image

% This function rescales the given image to a higher resolution width and height without
% modifying or distorying the critical contents/ components of the image 
    %% read image 
    img =  im2double(imread(image));
    
    %% split into 3 color channels
    img_red =  im2double(img(:,:,1));
    img_green =  im2double(img(:,:,2));
    img_blue =  im2double(img(:,:,3));

    %% calculate resolution difference
    HEIGHT = size(img,1);
    WIDTH = size(img,2);
    diff_width = desired_width - WIDTH;
    diff_height = desired_height - HEIGHT;
    
    if(diff_width > 0)
        for iteration=1:diff_width

            %% obtain img grad for 3 channels
            [img_red_grad, ~] = imgradient(img_red);
            [img_green_grad, ~] = imgradient(img_green);
            [img_blue_grad, ~] = imgradient(img_blue);

            %% width & height needs to be recalculated in every seam removal
            HEIGHT = size(img_red, 1);
            WIDTH = size(img_red, 2);
            
            energy_img = zeros(HEIGHT, WIDTH);

            for i=1:HEIGHT
                for j=1:WIDTH
                    energy_img(i,j) = img_red_grad(i,j) + img_green_grad(i,j) + img_blue_grad(i,j);
                end
            end

            %% Create empty scoring matrix for horizontal and vertical
            scoring_vertical = zeros(HEIGHT, WIDTH);

            %% Fill the first row the same as the energy_img
            scoring_vertical(1,:) = energy_img(1,:);

            %% d)
            for i=2:HEIGHT
                for j=1:WIDTH
                    if j == 1
                        scoring_vertical(i,j) = energy_img(i,j) + min(energy_img(i-1,j),energy_img(i-1,j+1));
                    elseif j == WIDTH
                        scoring_vertical(i,j) = energy_img(i,j) + min(energy_img(i-1,j-1),energy_img(i-1,j));
                    else
                        scoring_vertical(i,j) = energy_img(i,j) + min(min(energy_img(i-1,j-1), energy_img(i-1,j)), energy_img(i-1,j+1));
                    end
                end
            end


            %% e)
            %% Create array that indexes the seam coordinates
            seam = zeros(HEIGHT,1);

            minimal_value = min(scoring_vertical(HEIGHT,:));
            %% find position of minimal value
            COL = find(scoring_vertical(HEIGHT,:) == minimal_value);

            seam(HEIGHT,1) = COL(1,1);

            %% locate seam
            for i=(HEIGHT-1):-1:1
                    if COL == 1
                         minimal_value = min(scoring_vertical(i,COL), scoring_vertical(i,COL+1));
                    elseif COL == WIDTH
                        minimal_value = min(scoring_vertical(i,COL-1), scoring_vertical(i,COL));
                    else
                        minimal_value = min(min(scoring_vertical(i,COL-1), scoring_vertical(i,COL)), scoring_vertical(i,COL+1));
                    end

                    COL = find(scoring_vertical(i,:) == minimal_value);

                    %% COL can have more than 1 value 
                    %% must suppress result to appropriate one
                    if (size(COL,2) > 1)
                        for j=1:size(COL,2)
                            if (COL(1,j) == (seam(i+1,1)+1))
                                temp = COL(1,j);
                            elseif (COL(1,j) == (seam(i+1,1)-1))
                                temp = COL(1,j);
                            elseif (COL(1,j) == seam(i+1,1))
                                temp = COL(1,j);
                            end
                        end
                        COL = temp;
                    end        
                    seam(i,1) = COL;
            end

            %% Adding elements from column of image

            new_image_red = zeros(HEIGHT,WIDTH+1);
            new_image_green = zeros(HEIGHT,WIDTH+1);
            new_image_blue = zeros(HEIGHT,WIDTH+1);

            for i=1:size(seam,1)
                if ( seam(i,1) == 1 )        
                    temp_red = horzcat(img_red(i,1), img_red(i,seam(i,1):WIDTH));
                    temp_green = horzcat(img_green(i,1), img_green(i,seam(i,1):WIDTH));
                    temp_blue = horzcat(img_blue(i,1), img_blue(i,seam(i,1):WIDTH));
                elseif (seam(i,1) == WIDTH)
                    temp_red = horzcat(img_red(i,1:WIDTH),img_red(i,WIDTH));
                    temp_green = horzcat(img_green(i,1:WIDTH),img_green(i,WIDTH));
                    temp_blue = horzcat(img_blue(i,1:WIDTH), img_blue(i,WIDTH));
                else
                    temp_red = horzcat(horzcat(img_red(i,1:seam(i,1)), img_red(i,seam(i,1)) ), img_red(i,seam(i,1)+1:WIDTH));
                    temp_green = horzcat(horzcat(img_green(i,1:seam(i,1)), img_green(i,seam(i,1)) ), img_green(i,seam(i,1)+1:WIDTH));
                    temp_blue = horzcat(horzcat(img_blue(i,1:seam(i,1)), img_green(i,seam(i,1)) ), img_blue(i,seam(i,1)+1:WIDTH));
                end
                new_image_red(i,:) = temp_red;
                new_image_green(i,:) = temp_green;
                new_image_blue(i,:) = temp_blue;
            end
            img_red = new_image_red;
            img_green = new_image_green;
            img_blue = new_image_blue;
        end
    end
    
    %% For removing seams horizontally
    if(diff_height > 0)
        for iteration=1:diff_height

            img_red = img_red';
            img_green = img_green';
            img_blue = img_blue';
            
            %% obtain img grad for 3 channels
            [img_red_grad, ~] = imgradient(img_red);
            [img_green_grad, ~] = imgradient(img_green);
            [img_blue_grad, ~] = imgradient(img_blue);
            
            %% width & height needs to be recalculated in every seam removal
            HEIGHT = size(img_red, 1);
            WIDTH = size(img_red, 2);

            energy_img = zeros(HEIGHT, WIDTH);

            for i=1:HEIGHT
                for j=1:WIDTH
                    energy_img(i,j) = img_red_grad(i,j) + img_green_grad(i,j) + img_blue_grad(i,j);
                end
            end

            %% Create empty scoring matrix for horizontal and vertical
            scoring_horizontal = zeros(HEIGHT, WIDTH);

            %% Fill the first row the same as the energy_img
            scoring_horizontal(1,:) = energy_img(1,:);

            %% d)
            for i=2:HEIGHT
                for j=1:WIDTH
                    if j == 1
                        scoring_horizontal(i,j) = energy_img(i,j) + min(energy_img(i-1,j),energy_img(i-1,j+1));
                    elseif j == WIDTH
                        scoring_horizontal(i,j) = energy_img(i,j) + min(energy_img(i-1,j-1),energy_img(i-1,j));
                    else
                        scoring_horizontal(i,j) = energy_img(i,j) + min(min( energy_img(i-1,j-1), energy_img(i-1,j)), energy_img(i-1,j+1));
                    end
                end
            end


            %% e)
            %% Create array that indexes the seam coordinates
            seam = zeros(HEIGHT,1);

            minimal_value = min(scoring_horizontal(HEIGHT,:));
            %% find position of minimal value
            COL = find(scoring_horizontal(HEIGHT,:) == minimal_value);

            seam(HEIGHT,1) = COL(1,1);
            COL = COL(1,1);

            %% f)
            for i=(HEIGHT-1):-1:1
                    if COL == 1
                         minimal_value = min(scoring_horizontal(i,COL), scoring_horizontal(i,COL+1));
                    elseif COL == WIDTH
                        minimal_value = min(scoring_horizontal(i,COL-1), scoring_horizontal(i,COL));
                    else
                        minimal_value = min(min(scoring_horizontal(i,COL-1), scoring_horizontal(i,COL)), scoring_horizontal(i,COL+1));
                    end

                    COL = find(scoring_horizontal(i,:) == minimal_value);

                    %% COL can have more than 1 value 
                    %% must suppress result to appropriate one
                    if (size(COL,2) > 1)
                        for j=1:size(COL,2)
                            if (COL(1,j) == (seam(i+1,1)+1))
                                temp = COL(1,j);
                            elseif (COL(1,j) == (seam(i+1,1)-1))
                                temp = COL(1,j);
                            elseif (COL(1,j) == seam(i+1,1))
                                temp = COL(1,j);
                            end
                        end
                        COL = temp;
                    end        
                    seam(i,1) = COL;
            end

            %% Inserting elements from column of image

            new_image_red = zeros(HEIGHT,WIDTH+1);
            new_image_green = zeros(HEIGHT,WIDTH+1);
            new_image_blue = zeros(HEIGHT,WIDTH+1);

            for i=1:size(seam,1)
                if ( seam(i,1) == 1 )           
                    temp_red = horzcat(img_red(i,1), img_red(i,seam(i,1):WIDTH));
                    temp_green = horzcat(img_green(i,1), img_green(i,seam(i,1):WIDTH));
                    temp_blue = horzcat(img_blue(i,1), img_blue(i,seam(i,1):WIDTH));
                elseif (seam(i,1) == WIDTH)
                    temp_red = horzcat(img_red(i,1:WIDTH),img_red(i,WIDTH));
                    temp_green = horzcat(img_green(i,1:WIDTH),img_green(i,WIDTH));
                    temp_blue = horzcat(img_blue(i,1:WIDTH), img_blue(i,WIDTH));
                else
                    temp_red = horzcat(horzcat(img_red(i,1:seam(i,1)), img_red(i,seam(i,1)) ), img_red(i,seam(i,1)+1:WIDTH));
                    temp_green = horzcat(horzcat(img_green(i,1:seam(i,1)), img_green(i,seam(i,1)) ), img_green(i,seam(i,1)+1:WIDTH));
                    temp_blue = horzcat(horzcat(img_blue(i,1:seam(i,1)), img_green(i,seam(i,1)) ), img_blue(i,seam(i,1)+1:WIDTH));
                end
                new_image_red(i,:) = temp_red;
                new_image_green(i,:) = temp_green;
                new_image_blue(i,:) = temp_blue;
            end
            img_red = new_image_red';
            img_green = new_image_green';
            img_blue = new_image_blue';
        end
    end
    
    final_image = cat(3,img_red,img_green,img_blue);
    
    imshow(final_image, []);
end


