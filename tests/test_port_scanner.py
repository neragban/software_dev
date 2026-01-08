import pytest
import socket
from unittest.mock import patch, MagicMock
import sys
import os

# Add parent directory to path to import the scanner module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import functions from the scanner
from Multi_Thread_Port_Scanner import guess_device


class TestGuessDevice:
    """Test device detection logic."""

    def test_windows_device_detection(self):
        """Test detection of Windows devices by SMB ports."""
        ports = [445, 139, 135, 80]
        assert guess_device(ports) == "Windows device"

    def test_linux_device_detection(self):
        """Test detection of Linux/Unix devices by SSH port."""
        ports = [22, 80, 443]
        assert guess_device(ports) == "Linux / Unix / Raspberry Pi"

    def test_unknown_device(self):
        """Test unknown device when no identifying ports are found."""
        ports = [8080, 9000]
        assert guess_device(ports) == "Unknown device"

    def test_empty_ports_list(self):
        """Test behavior with empty ports list."""
        ports = []
        assert guess_device(ports) == "Unknown device"

    def test_windows_takes_precedence(self):
        """Test that Windows detection takes precedence over Linux when both ports present."""
        ports = [445, 22, 80]
        result = guess_device(ports)
        assert result == "Windows device"


class TestPortScanning:
    """Test port scanning functionality."""

    @patch("socket.socket")
    def test_open_port_detection(self, mock_socket_class):
        """Test successful connection to open port."""
        mock_socket = MagicMock()
        mock_socket_class.return_value = mock_socket
        
        from Multi_Thread_Port_Scanner import scan_port
        
        # Mock successful connection
        mock_socket.connect.return_value = None
        
        scan_port("127.0.0.1", 80)
        
        # Verify socket was created and connected
        mock_socket_class.assert_called_once()
        mock_socket.connect.assert_called_once_with(("127.0.0.1", 80))

    @patch("socket.socket")
    def test_closed_port_detection(self, mock_socket_class):
        """Test connection failure to closed port."""
        mock_socket = MagicMock()
        mock_socket_class.return_value = mock_socket
        
        from Multi_Thread_Port_Scanner import scan_port
        
        # Mock connection error
        mock_socket.connect.side_effect = socket.error("Connection refused")
        
        # Should not raise exception
        scan_port("127.0.0.1", 9999)
        
        mock_socket.close.assert_called_once()


class TestCommonPorts:
    """Test common ports configuration."""

    def test_common_ports_defined(self):
        """Test that COMMON_PORTS dictionary is properly defined."""
        from Multi_Thread_Port_Scanner import COMMON_PORTS
        
        assert isinstance(COMMON_PORTS, dict)
        assert 22 in COMMON_PORTS
        assert COMMON_PORTS[22] == "SSH"
        assert 80 in COMMON_PORTS
        assert COMMON_PORTS[80] == "HTTP"
        assert 443 in COMMON_PORTS
        assert COMMON_PORTS[443] == "HTTPS"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--cov=Multi_Thread_Port_Scanner", "--cov-report=html"])
