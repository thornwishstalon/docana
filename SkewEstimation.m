classdef SkewEstimation < handle
    %SKEWESTIMATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        img;
        width;
        height;
        min_angle= -15;
        max_angle= 15;
        %step= 0.5;
        step= 2;
        
        sectionWindowSize= 4;
        
        allowResize=0;
        showflag=1;
        debugflag=0;
        gssFlag=1;
        
    end
    
    methods
        function obj = SkewEstimation(allowResize,debug,showflag)
            % constructor, nothing to do here
            obj.allowResize=allowResize;
            obj.debugflag=debug;
            obj.showflag= showflag;
            
        end
        
        function skew= calcAngle(obj,path)
            obj.openPath(path);
            
            angle = obj.min_angle:obj.step:obj.max_angle;
            
            
            V_alpha= zeros(size(angle));
            
            k=1;
            
            
            %coarse angle resolution
            for alpha = obj.min_angle:obj.step:obj.max_angle
                %flip angle (deal witch image coordinates) and map to identity-circle orintation
                a= mod(abs(alpha-360),360);
                if(obj.debugflag==1)
                    fprintf('doing: %f degree -> %f degree \n', alpha,a);
                end
                %                 d= zeros(obj.height,1);
                %
                %                 for y = 1:obj.height
                %                     d(y)= obj.getH(y,alpha);
                %                 end
                %
                %                 dt= [0 ; d];
                %                 d= [d; 0];
                %
                %                 v= abs(d-dt) .^2;
                
                %degree to radians
                a = a * (pi/180);
                V_alpha(k) = obj.getValueForAlpha(a);
                
                k = k + 1;
            end
            
            
            lineLength = min(500, obj.width/2);
            [maxValue, id] = max(V_alpha);
            maxAngle= angle(id);
            skew= maxAngle;
            if(obj.debugflag==1)
                fprintf('coarse seach: %f\n', skew)
            end
            
            
            if(obj.gssFlag==1)
                %fine resolution search
                w = obj.sectionWindowSize/2;
                a= maxAngle - w;
                b= maxAngle + w;
                
                
                if(a > obj.max_angle)
                    a = obj.max_angle;
                elseif(a < obj.min_angle)
                    a = obj.min_angle;
                end
                
                if(b > obj.max_angle)
                    b = obj.max_angle;
                elseif(b < obj.min_angle)
                    b = obj.min_angle;
                end
                
                    
                
                eps=0.00001;
                N= 30;

                if(obj.debugflag==1)
                    disp('golden section search:');
                    fprintf('a %f, b%f \n ',a,b);
                end
                maxAngle = obj.gss(a,b,eps,N);
                skew= maxAngle;
                if(obj.debugflag==1)
                    fprintf('golden search result: %f degree \n ',skew);
                end

            end
            %draw stuff
            
            
            %normalize angle
            maxAngle=  mod(abs(maxAngle-360),360);
            
            
            if(obj.showflag==1)
                %defining lines
                x(1) = (obj.width/2);% - lineLength/2;
                y(1) = (obj.height/2);% - lineLength/2;
                
                x(2) = x(1) + lineLength * cosd(maxAngle);
                y(2) = y(1) + lineLength * sind(maxAngle);
                
                x_min(1) = (obj.width/2);% - lineLength/2;
                y_min(1) = (obj.height/2);% - lineLength/2;
                
                minA= angle(1);
                minA= mod(abs(minA-360),360);
                
                maxA= angle(end);
                maxA= mod(abs(maxA-360),360);
                
                x_min(2) = x(1) + lineLength * cosd(minA);
                y_min(2) = y(1) + lineLength * sind(minA);
                
                x_max(1) = (obj.width/2);% - lineLength/2;
                y_max(1) = (obj.height/2);% - lineLength/2;
                
                x_max(2) = x(1) + lineLength * cosd(maxA);
                y_max(2) = y(1) + lineLength * sind(maxA);
                
                x_0(1) = (obj.width/2);% - lineLength/2;
                y_0(1) = (obj.height/2);% - lineLength/2;
                
                x_0(2) = x_0(1) + lineLength ;
                y_0(2) = y_0(1);
                
                
                %drawing
                figure('name', path);
                subplot(1,2,1), bar(angle, V_alpha);
                
                % red is estimated skew. blue is min and max angle, green
                % is zero degree
                subplot(1,2,2), imshow(obj.img), hold on, plot(x,y, 'Color', 'red'),  plot(x_0,y_0, 'Color', 'green'), plot(x_min,y_min, 'Color', 'blue') ,plot(x_max,y_max, 'Color', 'blue') ;
                hold off;
                
            end;
        end
        
        function openPath(obj, path)
            obj.img = 0;
            obj.img = imread(path);
            
            if(~islogical(obj.img))
                %transform in binary image if not already binary
                obj.img= im2bw(obj.img,0.8);
            end
            
            %downsampling of image to speed up computation of projection
            %profiles
            
            
            if((obj.allowResize==1) && (sum(size(obj.img) > [1024, 1024]) > 0) )
                obj.img = imresize(obj.img, max([768,1280]/size(obj.img)) );
                size(obj.img);
            end
            
            %median filter to remove noise
            %   currently ignored
            %obj.img = medfilt2(obj.img);
            
            [obj.height,obj.width] = size(obj.img);
            
            %erase small connected components aka speckle removal
            %CC = bwconncomp(obj.img);
            %numPixels = cellfun(@numel,CC.PixelIdxList);
            %idx = numPixels == 3;
            %obj.img(CC.PixelIdxList{idx}) = 0;
            
        end
        
        
        function h = getH(obj, y, alpha)
            x= 1:obj.width;
            
            
            %precompute sin and cos for alpha
            sin_alpha = sin(alpha);
            cos_alpha= cos(alpha);
            
            x_n  = round(x * cos_alpha - y * sin_alpha);
            y_n = round(x * sin_alpha + y * cos_alpha);
            
            
            %handle indices outside the image
            a=  x_n > 0 & x_n < obj.width;
            b=   y_n > 0 & y_n < obj.height;
            
            %logical mask, where indices are outside image
            c= a & b;
            
            x_n = x_n(c);
            y_n = y_n(c);
            
            if(sum(c) > 0)
                
                b= sub2ind(size(obj.img),y_n,x_n );
                %get values from image
                f= obj.img(b);
                
                %sum values for projection
                h= sum(sum(~f));
            else
                h=0;
            end
        end
        
        
        function v = getValueForAlpha(obj,alpha)
            d= zeros(obj.height,1);
            
            for y = 1:obj.height
                d(y)= obj.getH(y,alpha);
            end
            
            
            d_1= d(2:end);
            d= d(1:end-1);
            
            v= sum(abs(d_1 - d) .^2);
            
        end
        
        
        
        function angle= gss(obj,a,b,eps,N)
            a= mod(abs(a-360),360);
            a = a * (pi/180);
            
            b = mod(abs(b-360),360);
            b = b * (pi/180);
            
            c = (-1+sqrt(5))/2;
            x1 = c*a + (1-c)*b;
            fx1 = obj.getValueForAlpha(x1);
            x2 = (1-c)*a + c*b;
            fx2 = obj.getValueForAlpha(x2);
            if(obj.debugflag==1)
                fprintf('------------------------------------------------------\n');
                fprintf(' x1\t\tx2\t\tf(x1)\t\tf(x2)\t\tb - a\n');
                fprintf('------------------------------------------------------\n');
                fprintf('%f\t%f\t%f\t%f\t%f\n', 360 - x1* (180/pi), 360 - x2* (180/pi), fx1, fx2, b-a);
            end
            for i = 1:N-2
                if fx1 > fx2
                    b = x2;
                    x2 = x1;
                    fx2 = fx1;
                    x1 = c*a + (1-c)*b;
                    fx1 = obj.getValueForAlpha(x1);
                else
                    a = x1;
                    x1 = x2;
                    fx1 = fx2;
                    x2 = (1-c)*a + c*b;
                    fx2 = obj.getValueForAlpha(x2);
                end;
                if(obj.debugflag==1)
                    fprintf('%f\t%f\t%f\t%f\t%f\n', 360 - x1* (180/pi),360 - x2* (180/pi), fx1, fx2, b-a);
                end
                if (abs(b-a) < eps)
                    if(obj.debugflag==1)
                        fprintf('succeeded after %d steps\n', i);
                    end
                    angle=360-( a * (180/pi));
                    
                    if(angle > obj.max_angle)
                        angle= angle-360;
                    end
                    return;
                end;
            end;
            
            
        end
        
        function testProjection(obj,path)
            obj.openPath(path);
            
            x= 1:obj.width;
            y= obj.height/2
            alpha = -15;
            alpha= mod(abs(alpha*(-1)-360),360)
            %degree to rad
            alpha = alpha * (pi/180)
            
            %precompute sin and cos for alpha
            sin_alpha = sin(alpha);
            cos_alpha= cos(alpha);
            
            
            x_n  = round(x * cos_alpha - (y * sin_alpha));
            y_n = round(x * sin_alpha + (y * cos_alpha));
            
            %handle indices outside the image
            a=  x_n > 0 & x_n < obj.width;
            b=   y_n > 0 & y_n < obj.height;
            
            %logical mask, where indices are outside image
            c= a & b;
            
            x_n = x_n(c);
            y_n = y_n(c);
            
            
            b= sub2ind(size(obj.img),y_n,x_n );
            
            if(sum(c) > 0)
                obj.img(b) = 0;
                imshow(obj.img);
                
            else
                disp('nothing to show');
                imshow(b)
            end
            
            
        end
        
    end
end

