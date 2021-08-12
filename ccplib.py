import os
from ciscoconfparse import CiscoConfParse
from robot.api.deco import library, keyword

@library
class CCPLib(object):
    def __init__(self, 
            config_file: str,
            config_dir: str = '../configs') -> None:
        self.__config_dir = config_dir
        self.__config_file = config_file

    @property
    def config_dir(self) -> str:
        return self.__config_dir

    @property
    def config_file(self) -> str:
        return self.__config_file     

    @keyword
    def parse_config_file(self) -> CiscoConfParse:
        """ """
        path = os.path.expanduser(os.path.join(self.config_dir, self.config_file))

        if not os.path.exists(path):
            raise AssertionError('Config file \'{0}\' does not exist.'.format(path))
        
        return CiscoConfParse(config=path, ignore_blank_lines=False)
