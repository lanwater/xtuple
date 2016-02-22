UPDATE pkghead SET pkghead_notes = 'Feature is core in 4.10.0 and later. ' || pkghead_notes;
-- looks redundant but it handles the case where the pkg has never been installed
SELECT disablePackage(pkghead_name) FROM pkghead WHERE pkghead_name = 'info1099';
