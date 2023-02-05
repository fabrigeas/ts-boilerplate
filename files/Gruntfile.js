module.exports = function (grunt) {
  const pkg = grunt.file.readJSON('package.json');

  grunt.initConfig({
    pkg,
  });

  grunt.registerTask('sayHi', 'run prett', function () {
    grunt.log.writeln('Hello world');
  });

  grunt.registerTask('sayBye', 'run prett', function () {
    grunt.log.writeln('Bye world');
  });

  grunt.registerTask('default', ['sayHi']);
};
