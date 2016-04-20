% This script calls predictRLS_online for object, attributes and
% affordances.

% Author: Niklas Barkmeyer, 01.04.2016


%% Compute shape, material and affordance with GURLS on Caffe's FC7 features 
tic;

iterator=0;
while(iterator <6)
    %objects_28__labelnum = predictRLS_online('28_objects');
    %objects_7_labelnum = predictRLS_online('7_objects');
    shape_labelnum = predictRLS_online('attribute_shape');
    material_labelnum = predictRLS_online('attribute_material');
    affordance_labelnum = predictRLS_online('affordances');

    %% Translate numbers into strings
    load names;
    object_='Cup'; % Just for testing and consistency, not used in the final system!
    shape_=shape_names(shape_labelnum);
    material_=material_names(material_labelnum);
    affordance_=affordance_names(affordance_labelnum);

    disp('Caffe + GURLS detected: /n');
    disp(['Object: ',object_,', Shape: ', shape_, ', Material: ',material_, ', Affordance: ', affordance_]); 

    %% Define Ports
    LoadYarp;
    yarp.Network.init();
    import yarp.Port;
    mport1=Port; mport2=Port; mport3=Port; mport4=Port;
    %mport1.close(); mport2.close(); mport3.close(); mport4.close();

    mport1.open('/GURLS_object_out');
    mport2.open('/GURLS_material_out');
    mport3.open('/GURLS_shape_out');
    mport4.open('/GURLS_affordance_out');

    if(yarp.NetworkBase.isConnected('/GURLS_material_out', '/Prolog_material')==false) yarp.Network.connect('/GURLS_material_out', '/Prolog_material'); end
    if(yarp.NetworkBase.isConnected('/GURLS_shape_out', '/Prolog_shape')==false) yarp.Network.connect('/GURLS_shape_out', '/Prolog_shape'); end
    if(yarp.NetworkBase.isConnected('/GURLS_affordance_out', '/Prolog_affordance')==false) yarp.Network.connect('/GURLS_affordance_out', '/Prolog_affordance'); end

    %yarp.Network.Connect('/GURLS_material_out', '/Prolog_material');
    %yarp.Network.Connect('/GURLS_shape_out', '/Prolog_shape');
    %yarp.Network.Connect('/GURLS_affordance_out', '/Prolog_affordance');
    
    disp('Matlab ports are open');

    % Set messages
    b1=yarp.Bottle; b2=yarp.Bottle; b3=yarp.Bottle; b4=yarp.Bottle;

    b1.fromString(object_);
    mport1.write(b1);

    b2.fromString(material_);
    mport2.write(b2);

    b3.fromString(shape_);
    mport3.write(b3);

    b4.fromString(affordance_);
    mport4.write(b4);

    disp('Messages sent');
    mport1.close(); mport2.close(); mport3.close(); mport4.close();
    
    
    
    iterator=iterator+1;
end
