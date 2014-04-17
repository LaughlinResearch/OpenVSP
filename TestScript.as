

const double PI = 4.0 * atan(1.0);

string vec3dString(const vec3d v)
{
	return "(" + v.x() + ", " + v.y() + ", " + v.z() + ")";
}

string intString( int i )
{
	return " " + i;
}

bool CloseVec3d( vec3d a, vec3d b, double tol )
{
	double sum = (a.x()-b.x()) + (a.y()-b.y()) + (a.z()-b.z());

	if ( abs(sum) < tol )
		return true;

	return false;
}

double tol = 0.00001;
void main()
{
	Print(string("Begin Scripting Test"));
	TestVec3d();
	TestMatrix();
	TestProxy();


}

void TestVec3d()
{
	Print(string("--> Testing Vec3d"));

	//==== Test Vec3d ====//
	vec3d a();								// Default Constructor
	vec3d b(1.0, 2.0, 3.0);					// Init Constructor

	//===== Test Copy ====//
	a = b;									// Copy Constructor
	if ( !CloseVec3d( a, b, tol ) )					Print( " ---> Error: Vec3d Copy " );

	//===== Test Assignment ====//
	a.set_xyz( 2.0, 4.0, 6.0 );
	b.set_x( 2.0 );	b.set_y( 4.0 );	b.set_z( 6.0 );
	if ( !CloseVec3d( a, b, tol ) )					Print( "---> Error: Vec3d Assignment " );

	//===== Test Rotate ====//
	a.set_xyz( 1.0, 0.0, 0.0 );
	a.rotate_z( cos( 0.5*PI ), sin( 0.5*PI ) );
	a.rotate_x( cos( 0.5*PI ), sin( 0.5*PI ) );
	a.rotate_y( cos( 0.5*PI ), sin( 0.5*PI ) );
	if ( !CloseVec3d( a, vec3d(-1,0,0),tol ) )		Print( "---> Error: Vec3d Rotate " );

	//===== Test Scale/Offset/Reflect ====//
	a.set_xyz( 2.0, 2.0, 2.0 );
	a.scale_x( 2.0 );		a.scale_y( 2.0 );		a.scale_z( 2.0 );
	a.offset_x( 10.0 );		a.offset_y( 10.0 );		a.offset_z( 10.0 );
	if ( !CloseVec3d( a, vec3d( 14.0, 14.0, 14.0 ), tol ) ) 	Print( "---> Error: Vec3d Scale/Offset " );

	a.set_xyz( 1.0, 2.0, 3.0 );
	b = a.reflect_xy();
	a = b.reflect_xz();
	b = a.reflect_yz();
	if ( !CloseVec3d( b, vec3d( -1.0, -2.0, -3.0 ), tol ) ) 	Print( "---> Error: Vec3d Reflect " );

	//==== Test Mag ====//
	a.set_xyz( 1.0, 2.0, 3.0 );
	if ( abs( a.mag() - sqrt(14) ) > tol )						Print( "---> Error: Vec3d Mag " );

	//===== Test Operators ====//
	a.set_xyz( 2.0, 3.0, 4.0 );
	b.set_xyz( 3.0, 4.0, 5.0 );
	vec3d c = a + b;
	a = c - b;
	b = a * 2.0;
	c = b * a;
	a = c / 2.0;
	if ( !CloseVec3d( a, vec3d( 4.0, 9.0, 16.0 ), tol ) ) 		Print( "---> Error: Vec3d Operators " );

	//==== Test Dist ====//
	a.set_xyz( 2.0, 2.0, 2.0 );
	b.set_xyz( 3.0, 4.0, 5.0 );
	double d = dist(a, b);
	double d2 = dist_squared(a, b);
	if ( abs( d - sqrt(14) ) > tol && abs( d2 - 14 ) > tol )	Print( "---> Error: Vec3d Dist " );

	//==== Test Dot ====//
	a.set_xyz( 1.0, 2.0, 3.0 );
	b.set_xyz( 2.0, 3.0, 4.0 );
	if ( abs( dot(a,b) - 20 ) > tol )							Print( "---> Error: Vec3d Dot " );

	//==== Test Cross ====//
	a.set_xyz( 4.0, 0.0, 0.0 );
	b.set_xyz( 0.0, 3.0, 0.0 );
	c = cross(a,b);
	c.normalize();
	if ( !CloseVec3d( c, vec3d( 0.0, 0.0, 1.0 ), tol ) ) 		Print( "---> Error: Vec3d Cross  " );

	//==== Test Angle/Rotate ====//
	a.set_xyz( 1.0, 1.0, 0.0 );
	b.set_xyz( 1.0, 0.0, 0.0 );
	if ( abs( angle( a, b ) - PI/4 ) > tol )					Print( "---> Error: Vec3d Angle " );
	c.set_xyz( 0.0, 0.0, 1.0 );
	if ( abs( signed_angle( a, b, c ) - -PI/4 ) > tol )			Print( "---> Error: Vec3d SignedAngle " );

	c = RotateArbAxis( b, PI, a );
	if ( !CloseVec3d( c, vec3d( 0.0, 1.0, 0.0 ), tol ) ) 		Print( "---> Error: Vec3d RotateArbAxis  " );
}

void TestMatrix()
{
	Print(string("--> Testing Matrix4d"));

	//==== Test Matrix4d ====//
	Matrix4d m();							// Default Constructor
	m.loadIdentity();
	m.translatef( 1.0, 0.0, 0.0 );
	vec3d a = m.xform( vec3d( 0.0, 0.0, 0.0 ) );
	m.loadIdentity();
	m.rotateY( 90.0 );
	m.rotateX( 90.0 );
	m.rotateZ( 90.0 );
	m.rotate( PI/4, vec3d( 0.0, 0.0, 1.0 ) );		// Radians
	vec3d b = m.xform( a );
	if ( !CloseVec3d( b, vec3d(0.707107, -0.707107, 0.0), tol ) )
														Print( "---> Error: Matrix4d Rotate " );

	m.loadXZRef();
	m.scale( 10.0 );
	b = m.xform( vec3d(1,2,3) );
	m.loadXYRef();
	a = m.xform( b );
	m.loadYZRef();
	b = m.xform( a );
	if ( !CloseVec3d( b, vec3d(-10,-20,-30), tol ) )	Print( "---> Error: Matrix4d Reflect " );

	m.loadIdentity();
	m.rotateY( 10.0 );
	m.rotateX( 20.0 );
	m.rotateZ( 30.0 );
	a = vec3d( 1.0, 1.0, 1.0 );
	vec3d c = m.xform( a );
	m.affineInverse();
	b = m.xform( c );
	if ( !CloseVec3d( a, b, tol ) )						Print( "---> Error: Matrix4d Affine " );
}

void TestProxy()
{
	Print(string("--> Testing Proxy"));

	//==== Test Proxy Stuff =====//
	SetSaveInt( 23 );

//	//==== Get Vector of Vec3d From App =====//
	array< vec3d > @vec3d_array = GetProxyVec3dArray();
//	Print( formatInt( vec3d_array.size(), '' ) );
	//for ( uint i = 0 ; i < vec3d_array.size() ; i++ )
	//{
	//	Print( vec3dString( vec3d_array[i] ) );
	//}

	//array< vec3d > test_vec3d_array;
	//test_vec3d_array.insertLast( vec3d(1,2,3) );
	//test_vec3d_array.insertLast( vec3d(2,3,4) );
	//test_vec3d_array.insertLast( vec3d(3,4,5) );
	//SetVec3dArray( test_vec3d_array );

	TestProxy2();
}


void TestProxy2()
{
	if ( GetSaveInt() != 23 )						Print( "---> Error: Int Proxy  " );
}

void TestAPIScript()
{
	Print(string("--> Testing API Code"));

	ReadVSPFile( "TestGeomScript.vsp3" );
	WriteVSPFile( "TestWrite.vsp3", SET_ALL );

	//==== There Should Be Two Geoms in the File =====//
	array< string > @geom_ids = FindGeoms();
	if ( geom_ids.size() != 2 )						Print( "---> Error: API Read/Find  " );

	array< string > @type_array = GetGeomTypes();
	if ( type_array.size() < 1 )					Print( "---> Error: API GetGeomTypes  " );
	else if ( type_array[0] != "POD" )				Print( "---> Error: API GetGeomTypes  " );

	string gid0 = AddGeom( "POD", "" );
	SetGeomName( gid0, "ParentPod" );
	CutGeomToClipboard( gid0 );
	PasteGeomClipboard( "" );
	geom_ids = FindGeomsWithName("ParentPod");

	if ( geom_ids.size() != 1 )
	{
		Print( "---> API Add/Cut/Paste Geom " );
		return;
	}

	string gid1 = AddGeom( "POD", geom_ids[0] );
	SetGeomName( gid1, "ChildPod" );
	CopyGeomToClipboard( gid1 );
	PasteGeomClipboard( geom_ids[0] );
	geom_ids = FindGeoms();
	if ( geom_ids.size() != 5 )				Print( "---> Error: API Copy/Paste Geom  " );

	string geom_name = GetGeomName( gid1 );
	if ( geom_name != "ChildPod" )			Print( "---> Error: API GetGeomName  " );

	array< string > @parm_array = GetGeomParmIDs( gid1 );
	if ( parm_array.size() < 1 )			Print( "---> Error: API GetGeomParmIDs " );

	string lenid = GetParm( gid1, "Length", "Design" );
	if ( !ValidParm( lenid ) )				Print( "---> Error: API GetParm  " );

	string fuseid = AddGeom( "FUSELAGE", "" );
	int num_xsec_surfs = GetNumXSecSurfs( fuseid );
	if ( num_xsec_surfs != 1 )				Print( "---> Error: API GetNumXSecSurfs  " );

	string xsec_surf = GetXSecSurf( fuseid, 0 );
	int num_xsecs = GetNumXSec( xsec_surf );

    int xsec_type = GetXSecType( xsec_surf );
    if ( xsec_type != XSEC_FUSE )           Print( "---> Error: API GetXSecType  " );

	if ( num_xsecs < 1 )					Print( "---> Error: API GetXSecSurf/GetNumXSec  " );

	string xsec = GetXSec( xsec_surf, 0 );
	if ( xsec.size() == 0 )					Print( "---> Error: API GetXSec " );

	string add_xsec = AppendXSec( xsec_surf, XS_CIRCLE );
	CutXSec( xsec_surf, GetNumXSec( xsec_surf )-2 );
	CopyXSec( xsec_surf, GetNumXSec( xsec_surf )-1 );
	PasteXSec( xsec_surf, GetNumXSec( xsec_surf )-2 );
	InsertXSec( xsec_surf, XS_ROUNDED_RECTANGLE, 0 );
	ChangeXSecShape( xsec_surf, GetNumXSec( xsec_surf )-1, XS_POINT );

	xsec = GetXSec( xsec_surf, 1 );
	if ( GetXSecShape( xsec ) != XS_ROUNDED_RECTANGLE )
		Print( "---> Error: API ChangeXSec/GetShape " );

	SetXSecWidthHeight( xsec, 3.0, 6.0 );
	if ( abs( GetXSecWidth( xsec ) - 3.0 ) > tol )		Print( "---> Error: API Get/Set Width " );
	if ( abs( GetXSecHeight( xsec ) - 6.0 ) > tol )		Print( "---> Error: API Get/Set Height " );

	parm_array = GetXSecParmIDs( xsec );
	if ( parm_array.size() < 1 )						Print( "---> Error: API GetXSecParmIDs " );

	string wid = GetXSecParm( xsec, "RoundedRect_Width" );
	if ( !ValidParm( wid ) )							Print( "---> Error: API GetXSecParm " );

	ChangeXSecShape( xsec_surf, 0, XS_FILE_FUSE );
	xsec = GetXSec( xsec_surf, 0 );
	array< vec3d > @vec_array = ReadFileXSec( xsec, "../../TestXSec.fxs" );

	vec_array[1] = vec_array[1]*2.0;
	vec_array[3] = vec_array[3]*2.0;
	SetXSecPnts( xsec, vec_array );

	double wh_ratio = GetXSecWidth( xsec )/GetXSecHeight( xsec );
	if ( ( abs( wh_ratio ) - 2.0 ) > tol )				Print( "---> Error: API Read/Set XSecPnts " );

	//==== Sets ====//
	if ( GetNumSets() <= 0 )							Print( "---> Error: API GetNumSets " );
	SetSetName( 3, "SetFromScript" );
	if ( GetSetName( 3) != "SetFromScript" )			Print( "---> Error: API Get/Set Set Name " );

	array<string> @geom_arr1 = GetGeomSetAtIndex(3);
	array<string> @geom_arr2 = GetGeomSet("SetFromScript");

	if ( geom_arr1.size() != geom_arr2.size() )			Print( "---> Error: API GetGeomSet " );

	SetSetFlag( fuseid, 3, true );
	if ( !GetSetFlag( fuseid, 3 ) )						Print( "---> Error: API Set/Get Set Flag " );

	//==== Parms ====//
	SetParmVal( wid, 23.0 );
	if ( abs( GetParmVal(wid) - 23) > tol )				Print( "---> Error: API Parm Val Set/Get " );

	SetParmUpperLimit( wid, 13.0 );
	if ( abs( GetParmVal(wid) - 13) > tol )				Print( "---> Error: API SetParmUpperLimit " );

	SetParmUpperLimit( wid, 20.0 );
	SetParmLowerLimit( wid, 15.0 );
	if ( abs( GetParmVal(wid) - 15) > tol )				Print( "---> Error: API SetParmLowerLimit " );

	if ( GetParmType( wid ) != PARM_DOUBLE_TYPE )		Print( "---> Error: API GetParmType " );
	if ( GetParmName( wid ) != "RoundedRect_Width" )	Print( "---> Error: API GetParmName " );

	string cid = GetParmContainer(wid);
	if ( cid.size() == 0 )								Print( "---> Error: API GetParmContainer " );

	Update();

	//==== Bogus Call To Create API Error ====//
	SetParmVal( "BogusParmID", 23.0 );

	if ( !GetErrorLastCallFlag() )						Print( "---> Error: API GetErrorLastCallFlag " );

	//==== Check For API Errors ====//
	while ( GetNumTotalErrors() > 0 )
	{
		ErrorObj err = PopLastError();
		if ( err.GetErrorCode() != VSP_CANT_FIND_PARM)	Print( "---> Error: API PopLast" );
	}


	ClearVSPModel();

	//==== Import/Export ====//
	//gid0 = AddGeom( "POD", "" );
	//ExportFile( "ExportTest.stl", 0, EXPORT_STL );
	//string import_geom = ImportFile( "ExportTest.stl", IMPORT_STL, "" );
	//SetGeomName( import_geom, "ImportedGeom" );
	//SetGeomName( gid0, "ParentPod" );
	//InsertVSPFile( "TestGeomScript.vsp3", gid0 );
	//ClearVSPModel();
	//==== Results =====//
	WriteTestResults();

	array<string> @res_names_vec = GetAllResultsNames();

	bool found_name = false;
	for( int n = 0 ; n < int(res_names_vec.length()) ; n++ )
		if ( res_names_vec[n] == "Test_Results" ) found_name = true;

	if ( !found_name )										Print( "---> Error: API GetAllResultsNames" );


	if ( GetNumResults( "Test_Results" ) != 2 )				Print( "---> Error: API GetNumResults" );
	string res_id = FindResultsID( "Test_Results" );
	if ( res_id.size() == 0 )								Print( "---> Error: API FindResultsID" );

	array< string > @data_names = GetAllDataNames( res_id );
	if ( data_names.size() != 5 )							Print( "---> Error: API GetAllDataNames" );

	if ( GetNumData( res_id, "Test_Int" ) != 2 )			Print( "---> Error: API GetNumData " );
	array<int> @int_arr = GetIntResults( res_id, "Test_Int", 0 );
	if ( int_arr[0] != 1 )									Print( "---> Error: API GetIntResults" );
	int_arr = GetIntResults( res_id, "Test_Int", 1 );
	if ( int_arr[0] != 2 )									Print( "---> Error: API GetIntResults" );

	array<string> @str_arr = GetStringResults( res_id, "Test_String" );
	if ( str_arr[0] != "This Is A Test" )					Print( "---> Error: API GetStringResults" );

	array<double> @double_arr = GetDoubleResults( res_id, "Test_Double_Vec" );
	if ( double_arr.size() != 5 )							Print( "---> Error: API GetDoubleResults" );
	if ( abs( double_arr[4] - 4 ) > tol )					Print( "---> Error: API GetDoubleResults" );

	res_id = FindLatestResultsID( "Test_Results" );
	array<vec3d> @vec3d_vec = GetVec3dResults( res_id, "Test_Vec3d" );
	if ( !CloseVec3d( vec3d_vec[0], vec3d( 1.0, 2.0, 4.0 ), tol ))		Print( "---> Error: API GetVec3dResults" );

	//==== Test Mass Props ====//
	gid0 = AddGeom( "POD", "" );
	string sliced_id = ComputeMassProps( 0, 4 );
	string mass_res_id = FindLatestResultsID( "Mass_Properties" );
	double_arr = GetDoubleResults( mass_res_id, "Total_Mass" );
	if ( double_arr.size() != 1 )									Print( "---> Error: API ComputeMassProps" );
	CutGeomToClipboard( mass_res_id );

	//==== Test Comp Geom ====//
	gid1 = AddGeom( "POD", "" );
	string p0 = GetParm( gid1, "Length", "Design" );
	string p1 = GetParm( gid1, "X_Location", "XForm" );
	SetParmVal( p0, 12.0 );
	SetParmVal( p1, 4.0 );

	string mesh_id = ComputeCompGeom( 0, false, 0 );
	string comp_res_id = FindLatestResultsID( "Comp_Geom" );
	double_arr = GetDoubleResults( comp_res_id, "Wet_Area" );
	if ( double_arr.size() != 2 )									Print( "---> Error: API ComputeCompGeom" );

	//==== Test Comp Geom Mesh Results ====//
	string mesh_geom_res_id = CreateGeomResults( mesh_id, "Comp_Mesh" );
	int_arr = GetIntResults( mesh_geom_res_id, "Num_Tris" );
	if ( int_arr[0] < 4 )											Print( "---> Error: API CreateGeomResults" );
	CutGeomToClipboard( mesh_id );

	//==== Test Geom Results ====//
	string geom_xsec_results = CreateGeomResults( gid1, "Geom_XSecs" );
	file f;
	if( f.open("geom_xsecs.stl", "w") >= 0 )
	{
		f.writeString( "solid " + "\r\n" );

		int_arr = GetIntResults( geom_xsec_results, "Num_XSecs" );
		int num_xsecs = int_arr[0];

		for ( int i = 0 ; i < num_xsecs ; i++ )
		{
			array<vec3d> @p_vec = GetVec3dResults( geom_xsec_results, "XSec_Pnts", i );
			for ( int p = 0 ; p < int(p_vec.size()) - 1 ; p++ )
			{
				f.writeString( "facet normal 1 0 0 \r\n" );
				f.writeString( "  outer loop \r\n" );
				f.writeString( "    vertex " + p_vec[p].x() + " " + p_vec[p].y() + " " + p_vec[p].z() + "\r\n");
				f.writeString( "    vertex " + p_vec[p+1].x() + " " + p_vec[p+1].y() + " " + p_vec[p+1].z() + "\r\n");
				f.writeString( "    vertex " + (p_vec[p].x() + 0.1) + " " + p_vec[p].y() + " " + p_vec[p].z() + "\r\n");
				f.writeString( "  endloop \r\n" );
				f.writeString( "endfacet \r\n" );
			}
		}

		f.writeString( "endsolid \r\n" );
		f.close();
	}


	//==== Test Plane Slice ====//
	string slice_mesh_id = ComputePlaneSlice( 0, 6, vec3d(0.0, 0.0, 1.0), true );
	string pslice_results = FindLatestResultsID( "Slice" );
	double_arr = GetDoubleResults( pslice_results, "Slice_Area" );
	if ( double_arr.size() != 6 )									Print( "---> Error: API ComputePlaneSlice" );

	string slice_geom_results = CreateGeomResults( slice_mesh_id, "Slice_Mesh" );
	int_arr = GetIntResults( slice_geom_results, "Num_Slices" );
	if ( int_arr[0] != 6 )											Print( "---> Error: API CreateGeomResults (Slice)" );

	//===== Write File With Slice Triangles  ====//
	if( f.open("slice_tris.stl", "w") >= 0 )
	{
		int num_slices = int_arr[0];
		f.writeString( "solid " + "\r\n" );
		for ( int s = 0 ; s < num_slices ; s++ )
		{
			array<vec3d> @p0_vec =  GetVec3dResults( slice_geom_results, "Slice_Tris_Pnt_0", s );
			array<vec3d> @p1_vec =  GetVec3dResults( slice_geom_results, "Slice_Tris_Pnt_1", s );
			array<vec3d> @p2_vec =  GetVec3dResults( slice_geom_results, "Slice_Tris_Pnt_2", s );

			for ( int p = 0 ; p < int(p0_vec.size()) ; p++ )
			{
				f.writeString( "facet normal 1 0 0 \r\n" );
				f.writeString( "  outer loop \r\n" );
				f.writeString( "    vertex " + p0_vec[p].x() + " " + p0_vec[p].y() + " " + p0_vec[p].z() + "\r\n");
				f.writeString( "    vertex " + p1_vec[p].x() + " " + p1_vec[p].y() + " " + p1_vec[p].z() + "\r\n");
				f.writeString( "    vertex " + p2_vec[p].x() + " " + p2_vec[p].y() + " " + p2_vec[p].z() + "\r\n");
				f.writeString( "  endloop \r\n" );
				f.writeString( "endfacet \r\n" );
			}
		}
		f.writeString( "endsolid \r\n" );
		f.close();
	}

	CutGeomToClipboard( slice_mesh_id );

	//==== Test AWave Slice ====//
	mesh_id = ComputeAwaveSlice( 0, 4, 4, 22.0, true, vec3d(1.0, 0.0, 0.0), true );
	string aslice_results = FindLatestResultsID( "Slice" );
	if ( GetNumResults( "Slice" ) != 2 )							Print( "---> Error: API ComputeAwaveSlice" );

	DeleteResult( pslice_results );
	if ( GetNumResults( "Slice" ) != 1 )							Print( "---> Error: API DeleteResult" );

	DeleteAllResults();
	if ( GetNumResults( "Slice" ) != 0 )							Print( "---> Error: API DeleteAllResults" );

	ClearVSPModel();

	//==== Check For API Errors ====//
	while ( GetNumTotalErrors() > 0 )
	{
		ErrorObj err = PopLastError();
		Print( err.GetErrorString() );
	}

}

